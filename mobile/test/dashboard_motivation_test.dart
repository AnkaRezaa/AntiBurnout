import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/router/app_router.dart';
import 'package:mobile/app/router/route_paths.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/domain/entities/auth_user.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:mobile/features/dashboard/data/dashboard_motivations.dart';
import 'package:mobile/features/dashboard/presentation/widgets/motivation_card.dart';

class _Authenticated extends AuthController {
  @override
  AuthState build() => const AuthState.authenticated(
    AuthUser(id: 'test', email: 'test@example.com', name: 'Pengguna Uji'),
  );
}

String _quote(WidgetTester tester) => tester
    .widget<Text>(find.byKey(const ValueKey('dashboard-motivation-quote')))
    .data!;

void _prepareView(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> _tab(WidgetTester tester, String label) async {
  await tester.tap(
    find
        .descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text(label),
        )
        .last,
  );
  await tester.pumpAndSettle();
}

void main() {
  test(
    'daily motivation follows the local calendar, including date boundaries',
    () {
      for (final day in [
        DateTime(2024, 2, 28),
        DateTime(2024, 2, 29),
        DateTime(2024, 3, 1),
        DateTime(2026, 10, 16),
        DateTime(2026, 12, 31),
        DateTime(2027, 1, 1),
      ]) {
        final morning = DateTime(day.year, day.month, day.day, 7);
        final night = DateTime(day.year, day.month, day.day, 23, 59, 59);
        final tomorrow = DateTime(day.year, day.month, day.day + 1);
        expect(motivationForDate(morning), motivationForDate(night));
        expect(motivationForDate(day), isNot(motivationForDate(tomorrow)));
        expect(dashboardMotivations, contains(motivationForDate(day)));
      }
      // UTC timestamps must resolve to the same day as their local equivalent.
      for (final timestamp in [
        DateTime.utc(2026, 10, 16, 0, 15),
        DateTime.utc(2026, 10, 16, 23, 45),
      ]) {
        expect(
          motivationForDate(timestamp),
          motivationForDate(timestamp.toLocal()),
        );
      }
    },
  );

  testWidgets(
    'returning from each app tab preserves daily motivation and dashboard scroll',
    (tester) async {
      _prepareView(tester);
      final container = ProviderContainer(
        overrides: [authControllerProvider.overrideWith(_Authenticated.new)],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const AntiBurnoutApp(),
        ),
      );
      await tester.pumpAndSettle();

      final dashboardScroll = find.byKey(
        const PageStorageKey('dashboard-scroll'),
      );
      final scroll = tester.state<ScrollableState>(
        find
            .descendant(of: dashboardScroll, matching: find.byType(Scrollable))
            .first,
      );
      scroll.position.jumpTo(140);
      await tester.pumpAndSettle();
      final original = _quote(tester);

      for (final label in ['Riwayat', 'Survei', 'Profil']) {
        await _tab(tester, label);
        await _tab(tester, 'Beranda');
        expect(_quote(tester), original);
        expect(scroll.position.pixels, 140);
        expect(
          container
              .read(appRouterProvider)
              .routeInformationProvider
              .value
              .uri
              .path,
          RoutePaths.home,
        );

        // Re-selecting the current tab also preserves today's motivation.
        await _tab(tester, 'Beranda');
        expect(_quote(tester), original);
        expect(scroll.position.pixels, 140);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'recreating the dashboard on the same day preserves its motivation',
    (tester) async {
      _prepareView(tester);
      var now = DateTime(2026, 10, 16, 8);
      Future<void> showCard() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(body: MotivationCard(now: () => now)),
          ),
        );
        await tester.pumpAndSettle();
      }

      await showCard();
      final original = _quote(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      now = DateTime(2026, 10, 16, 22);
      await showCard();
      expect(_quote(tester), original);
      expect(_quote(tester), motivationForDate(now));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'ordinary rebuilds, theme changes and resizing preserve motivation',
    (tester) async {
      _prepareView(tester);
      late StateSetter update;
      var dark = false;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return MaterialApp(
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              home: const Scaffold(body: MotivationCard()),
            );
          },
        ),
      );
      await tester.pumpAndSettle();
      final original = _quote(tester);
      update(() {});
      await tester.pumpAndSettle();
      expect(_quote(tester), original);
      update(() => dark = true);
      await tester.pumpAndSettle();
      expect(_quote(tester), original);
      tester.view.physicalSize = const Size(1024, 1366);
      await tester.pumpAndSettle();
      expect(_quote(tester), original);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'motivation updates at local midnight without reopening the page',
    (tester) async {
      _prepareView(tester);
      var now = DateTime(2026, 10, 16, 23, 59, 59);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: MotivationCard(now: () => now)),
        ),
      );
      await tester.pump();
      final yesterday = _quote(tester);
      now = DateTime(2026, 10, 17);
      await tester.pump(const Duration(seconds: 1));
      expect(_quote(tester), isNot(yesterday));
      expect(_quote(tester), motivationForDate(now));
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('resuming the app after a date change refreshes motivation', (
    tester,
  ) async {
    _prepareView(tester);
    var now = DateTime(2026, 10, 16, 10);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: MotivationCard(now: () => now)),
      ),
    );
    await tester.pumpAndSettle();
    final yesterday = _quote(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = DateTime(2026, 10, 17, 8);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(_quote(tester), isNot(yesterday));
    expect(_quote(tester), motivationForDate(now));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('returning to an inactive tab refreshes a changed calendar day', (
    tester,
  ) async {
    _prepareView(tester);
    late StateSetter update;
    var active = true;
    var now = DateTime(2026, 10, 16, 18);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Scaffold(
              body: TickerMode(
                enabled: active,
                child: MotivationCard(now: () => now),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final yesterday = _quote(tester);
    update(() => active = false);
    await tester.pump();
    now = DateTime(2026, 10, 17, 9);
    update(() => active = true);
    await tester.pumpAndSettle();
    expect(_quote(tester), isNot(yesterday));
    expect(_quote(tester), motivationForDate(now));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('explicit motivation stays fixed even after the day changes', (
    tester,
  ) async {
    _prepareView(tester);
    late StateSetter update;
    var active = true;
    var now = DateTime(2026, 10, 16, 18);
    const customQuote = 'Motivasi khusus untuk halaman ini.';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Scaffold(
              body: TickerMode(
                enabled: active,
                child: MotivationCard(quote: customQuote, now: () => now),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(_quote(tester), customQuote);
    update(() => active = false);
    await tester.pump();
    now = DateTime(2026, 10, 17, 9);
    update(() => active = true);
    await tester.pumpAndSettle();
    expect(_quote(tester), customQuote);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
