import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/router/app_router.dart';
import 'package:mobile/app/router/route_paths.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:mobile/features/auth/di/auth_providers.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:mobile/features/profile/presentation/controllers/preferences_controller.dart';

Future<ProviderContainer> _startDark(WidgetTester tester) async {
  final container = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(FakeAuthRepository())],
  );
  addTearDown(container.dispose);
  container
      .read(preferencesControllerProvider.notifier)
      .setThemeMode(ThemeMode.dark);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const AntiBurnoutApp(),
    ),
  );
  // Welcome precaches image assets before displaying its content.
  await tester.runAsync(() async {
    final context = tester.element(find.byType(AntiBurnoutApp));
    await Future.wait([
      for (final asset in [
        'assets/images/LogoAntiBurnout.png',
        'assets/images/girl.png',
        'assets/images/left_leaf.png',
        'assets/images/right_leaf.png',
      ])
        precacheImage(AssetImage(asset), context),
    ]);
  });
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
  expect(
    container.read(authControllerProvider).status,
    AuthStatus.unauthenticated,
  );
  return container;
}

void main() {
  testWidgets(
    'Welcome gives its logo contrast without changing its footprint',
    (tester) async {
      final container = await _startDark(tester);
      final frameFinder = find.byKey(const ValueKey('welcome-logo-frame'));
      final darkFrame = tester.widget<Container>(frameFinder);
      final darkRect = tester.getRect(frameFinder);
      expect(
        (darkFrame.decoration as BoxDecoration).color,
        AppPalette.light.blob,
      );
      expect(find.bySemanticsLabel('Logo AntiBurnout'), findsOneWidget);
      expect(find.text('Mulai Sekarang'), findsOneWidget);
      expect(Theme.of(tester.element(frameFinder)).brightness, Brightness.dark);

      container
          .read(preferencesControllerProvider.notifier)
          .setThemeMode(ThemeMode.light);
      await tester.pumpAndSettle();
      expect(tester.widget<Container>(frameFinder).decoration, isNull);
      expect(tester.getRect(frameFinder), darkRect);
      expect(find.bySemanticsLabel('Logo AntiBurnout'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('dark mode adapts unauthenticated auth pages and input colors', (
    tester,
  ) async {
    final container = await _startDark(tester);
    final router = container.read(appRouterProvider);
    for (final location in [
      RoutePaths.welcome,
      RoutePaths.login,
      RoutePaths.register,
      RoutePaths.forgotPassword,
    ]) {
      router.go(location);
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, location);
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);
      final scaffold = tester.widget<Scaffold>(scaffoldFinder);
      expect(scaffold.backgroundColor, AppPalette.dark.background);
      expect(
        Theme.of(tester.element(scaffoldFinder)).brightness,
        Brightness.dark,
        reason: location,
      );
      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(fields.length, switch (location) {
        RoutePaths.welcome => 0,
        RoutePaths.login => 2,
        RoutePaths.register => 4,
        _ => 1,
      });
      for (final field in fields) {
        expect(field.style?.color, AppPalette.dark.navy, reason: location);
        expect(
          field.decoration?.fillColor,
          AppPalette.dark.surface,
          reason: location,
        );
        expect(
          field.decoration?.hintStyle?.color,
          AppPalette.dark.hint,
          reason: location,
        );
      }
      expect(tester.takeException(), isNull, reason: location);
    }
  });
}
