import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/router/app_router.dart';
import 'package:mobile/app/router/route_paths.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/auth/domain/entities/auth_user.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:mobile/features/profile/presentation/controllers/preferences_controller.dart';
import 'package:mobile/features/profile/presentation/pages/preferences_page.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_subpage_scaffold.dart';
import 'package:mobile/features/results/presentation/pages/result_page.dart';

class _SignedIn extends AuthController {
  @override
  AuthState build() => const AuthState.authenticated(
    AuthUser(
      id: 'theme-user',
      email: 'theme@example.com',
      name: 'Pengguna Tema',
    ),
  );
}

Future<ProviderContainer> _start(WidgetTester tester) async {
  final container = ProviderContainer(
    overrides: [authControllerProvider.overrideWith(_SignedIn.new)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const AntiBurnoutApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
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

Future<void> _tap(WidgetTester tester, String label) async {
  final target = find.text(label).last;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Brightness _brightness(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(BottomNavigationBar))).brightness;

Future<void> _preferences(WidgetTester tester) async {
  await _tab(tester, 'Profil');
  await _tap(tester, 'Preferensi');
}

void main() {
  testWidgets(
    'system follows device brightness; explicit choices override it',
    (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final container = await _start(tester);
      final router = container.read(appRouterProvider);
      await _preferences(tester);
      expect(_brightness(tester), Brightness.light);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(_brightness(tester), Brightness.dark);
      await _tap(tester, 'Terang');
      expect(_brightness(tester), Brightness.light);
      await _tap(tester, 'Gelap');
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpAndSettle();
      expect(_brightness(tester), Brightness.dark);
      await _tap(tester, 'Sistem');
      expect(_brightness(tester), Brightness.light);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(_brightness(tester), Brightness.dark);
      expect(container.read(appRouterProvider), same(router));
      expect(find.byType(PreferencesPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final small in [false, true]) {
    testWidgets(
      'theme choices fill content margins (${small ? 'small with large text' : 'normal'})',
      (tester) async {
        tester.view.physicalSize = small
            ? const Size(320, 568)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (small) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.8;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        await _start(tester);
        await _preferences(tester);
        final content = tester.getRect(find.byType(ProfileInfoCard));
        final options = [
          for (final mode in [
            ThemeMode.light,
            ThemeMode.dark,
            ThemeMode.system,
          ])
            tester.getRect(find.byKey(ValueKey('theme-option-${mode.name}'))),
        ];
        if (small) {
          for (final option in options) {
            expect(option.left, closeTo(content.left, 0.5));
            expect(option.right, closeTo(content.right, 0.5));
          }
        } else {
          expect(options[0].left, closeTo(content.left, 0.5));
          expect(options[2].right, closeTo(content.right, 0.5));
          expect(options[0].width, closeTo(options[1].width, 0.5));
          expect(options[1].width, closeTo(options[2].width, 0.5));
        }
        await _tap(tester, 'Gelap');
        expect(_brightness(tester), Brightness.dark);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('theme changes retain history detail and unfinished survey', (
    tester,
  ) async {
    final container = await _start(tester);
    final router = container.read(appRouterProvider);
    router.go(RoutePaths.resultFor('4'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<ResultPage>(find.byType(ResultPage)).assessmentId,
      '4',
    );
    await _preferences(tester);
    await _tap(tester, 'Gelap');
    await _tab(tester, 'Riwayat');
    expect(
      tester.widget<ResultPage>(find.byType(ResultPage)).assessmentId,
      '4',
    );
    await _tab(tester, 'Survei');
    await _tap(tester, 'Mulai Survei');
    await _tap(tester, 'Baik');
    await _tap(tester, 'Lanjut');
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await _tab(tester, 'Profil');
    await _tap(tester, 'Terang');
    await _tab(tester, 'Survei');
    expect(find.text('Langkah 2 dari 8'), findsOneWidget);
    expect(find.text('6.5'), findsOneWidget);
    expect(_brightness(tester), Brightness.light);
    expect(container.read(appRouterProvider), same(router));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark theme covers main pages and form surfaces', (tester) async {
    final container = await _start(tester);
    container
        .read(preferencesControllerProvider.notifier)
        .setThemeMode(ThemeMode.dark);
    for (final location in [
      RoutePaths.home,
      RoutePaths.survey,
      RoutePaths.history,
      RoutePaths.profile,
      RoutePaths.editProfile,
      RoutePaths.personalization,
      RoutePaths.preferences,
      RoutePaths.help,
      RoutePaths.about,
      RoutePaths.resultFor('4'),
      '${RoutePaths.resultFor('4')}/recommendations',
    ]) {
      container.read(appRouterProvider).go(location);
      await tester.pumpAndSettle();
      expect(_brightness(tester), Brightness.dark, reason: location);
      for (final element in find.byType(Scaffold).evaluate()) {
        final scaffold = element.widget as Scaffold;
        expect(
          scaffold.backgroundColor ?? Theme.of(element).scaffoldBackgroundColor,
          AppPalette.dark.background,
          reason: location,
        );
      }
      expect(tester.takeException(), isNull, reason: location);
    }
  });
}
