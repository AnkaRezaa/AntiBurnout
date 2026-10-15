import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/router/app_router.dart';
import 'package:mobile/app/router/route_paths.dart';
import 'package:mobile/features/auth/di/auth_providers.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:mobile/features/auth/presentation/pages/login_page.dart';
import 'package:mobile/features/auth/presentation/pages/register_page.dart';
import 'package:mobile/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:mobile/features/profile/presentation/controllers/personalization_controller.dart';
import 'package:mobile/features/profile/presentation/pages/personalization_page.dart';
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';

Future<ProviderContainer> _start(WidgetTester tester, String location) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(appRouterProvider).go(location);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const AntiBurnoutApp(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
  return container;
}

Future<void> _fill(WidgetTester tester, String hint, String value) async {
  final field = find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == hint,
  );
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
}

Future<void> _tap(WidgetTester tester, String label) async {
  final target = find.text(label).last;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _register(
  WidgetTester tester, {
  String email = 'baru@example.com',
}) async {
  await _fill(tester, 'Nama Lengkap', 'Pengguna Baru');
  await _fill(tester, 'Email', email);
  await _fill(tester, 'Kata Sandi', '123456');
  await _fill(tester, 'Konfirmasi Kata Sandi', '123456');
  await _tap(tester, 'Daftar');
}

void main() {
  testWidgets('registration opens personalization with an active session', (
    tester,
  ) async {
    final container = await _start(tester, RoutePaths.register);
    await _register(tester);
    final auth = container.read(authControllerProvider);
    expect(auth.status, AuthStatus.authenticated);
    expect(auth.user?.name, 'Pengguna Baru');
    expect(auth.justRegistered, isTrue);
    expect(find.byType(PersonalizationPage), findsOneWidget);
    expect(find.byType(LoginPage, skipOffstage: false), findsNothing);
    expect(find.byType(RegisterPage, skipOffstage: false), findsNothing);
    expect(
      container.read(personalizationControllerProvider).userId,
      auth.user?.id,
    );
    expect(container.read(personalizationControllerProvider).isLoaded, isTrue);
    final session = container.read(authRepositoryProvider).getCurrentUser();
    await tester.pump(const Duration(milliseconds: 300));
    expect((await session)?.id, auth.user?.id);

    await _tap(tester, 'Tambahan');
    await _tap(tester, 'Simpan Personalisasi');
    expect(find.byType(DashboardPage), findsOneWidget);
    expect(container.read(authControllerProvider).justRegistered, isFalse);
    expect(find.text('Pengguna Baru!'), findsOneWidget);
    await tester.tap(find.byTooltip('Buka profil'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.byType(PersonalizationPage), findsNothing);

    // A later login with this account uses the normal Dashboard destination.
    await container.read(authControllerProvider.notifier).logout();
    container.read(appRouterProvider).go(RoutePaths.login);
    await tester.pumpAndSettle();
    await _fill(tester, 'Email', 'baru@example.com');
    await _fill(tester, 'Kata Sandi', '123456');
    await _tap(tester, 'Masuk');
    expect(find.byType(DashboardPage), findsOneWidget);
    expect(find.byType(PersonalizationPage), findsNothing);
    expect(container.read(authControllerProvider).justRegistered, isFalse);
    expect(tester.takeException(), isNull);
  });

  for (final android in [false, true]) {
    testWidgets(
      'registration personalization Back goes to Dashboard (${android ? 'Android' : 'UI'})',
      (tester) async {
        final container = await _start(tester, RoutePaths.register);
        await _register(tester);
        if (android) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(find.byTooltip('Kembali ke beranda'));
        }
        await tester.pumpAndSettle();
        expect(find.byType(DashboardPage), findsOneWidget);
        expect(container.read(authControllerProvider).justRegistered, isFalse);
        container.read(appRouterProvider).go(RoutePaths.login);
        await tester.pumpAndSettle();
        expect(find.byType(DashboardPage), findsOneWidget);
        expect(find.byType(LoginPage, skipOffstage: false), findsNothing);
        await tester.tap(find.byTooltip('Buka profil'));
        await tester.pumpAndSettle();
        expect(find.byType(ProfilePage), findsOneWidget);
        expect(find.byType(PersonalizationPage), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('duplicate registration stays on the form without a session', (
    tester,
  ) async {
    final container = await _start(tester, RoutePaths.register);
    await _register(tester, email: 'dummy@example.com');
    expect(find.byType(RegisterPage), findsOneWidget);
    expect(find.text('Email sudah terdaftar.'), findsOneWidget);
    expect(
      container.read(authControllerProvider).status,
      AuthStatus.unauthenticated,
    );
    expect(container.read(authControllerProvider).user, isNull);
    expect(find.byType(PersonalizationPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'login opens Dashboard; profile personalization returns to Profile',
    (tester) async {
      final container = await _start(tester, RoutePaths.login);
      await _fill(tester, 'Email', 'dummy@example.com');
      await _fill(tester, 'Kata Sandi', '123456');
      await _tap(tester, 'Masuk');
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(find.byType(PersonalizationPage), findsNothing);
      expect(container.read(authControllerProvider).justRegistered, isFalse);
      await tester.tap(find.byTooltip('Buka profil'));
      await tester.pumpAndSettle();
      await _tap(tester, 'Personalisasi Profil');
      expect(find.byTooltip('Kembali ke profil'), findsOneWidget);
      await _tap(tester, 'Tambahan');
      await _tap(tester, 'Simpan Personalisasi');
      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.byType(PersonalizationPage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed login stays on Login without opening personalization', (
    tester,
  ) async {
    final container = await _start(tester, RoutePaths.login);
    await _fill(tester, 'Email', 'dummy@example.com');
    await _fill(tester, 'Kata Sandi', 'incorrect');
    await _tap(tester, 'Masuk');
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Email atau kata sandi tidak sesuai.'), findsOneWidget);
    expect(
      container.read(authControllerProvider).status,
      AuthStatus.unauthenticated,
    );
    expect(find.byType(PersonalizationPage), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
