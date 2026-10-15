import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/router/app_router.dart';
import 'package:mobile/app/router/route_paths.dart';
import 'package:mobile/core/responsive/app_scale.dart';
import 'package:mobile/features/auth/domain/entities/auth_user.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile/shared/widgets/app_back_button.dart';
import 'package:mobile/shared/widgets/app_page_header.dart';

class _Authenticated extends AuthController {
  @override
  AuthState build() => const AuthState.authenticated(
    AuthUser(id: 'header-test', email: 'header@example.com', name: 'Pengguna'),
  );
}

Future<ProviderContainer> _start(WidgetTester tester, Size viewport) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
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
  return container;
}

Future<void> _go(
  WidgetTester tester,
  ProviderContainer container,
  String location,
) async {
  container.read(appRouterProvider).go(location);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: location);
}

Finder _headerTitle(String title) =>
    find.descendant(of: find.byType(AppPageHeader), matching: find.text(title));

Finder get _backIcon => find.descendant(
  of: find.byType(AppBackButton),
  matching: find.byIcon(Icons.chevron_left_rounded),
);

Finder get _backButton => find.descendant(
  of: find.byType(AppBackButton),
  matching: find.byType(IconButton),
);

void _expectSameAnchor(Offset actual, Offset reference, String page) {
  expect(actual.dx, closeTo(reference.dx, 0.1), reason: '$page left edge');
  expect(actual.dy, closeTo(reference.dy, 0.1), reason: '$page top edge');
}

void main() {
  for (final viewport in [
    const Size(390, 844),
    const Size(1024, 1366),
    const Size(1440, 900),
  ]) {
    testWidgets(
      'page headers share dashboard and personalization anchors at $viewport',
      (tester) async {
        final container = await _start(tester, viewport);
        final dashboardAnchor = tester.getTopLeft(find.text('Halo,'));
        await _go(tester, container, RoutePaths.profile);
        final profileTitle = find.descendant(
          of: find.byType(ProfilePage),
          matching: find.text('Profil'),
        );
        final profileContext = tester.element(profileTitle);
        final profileAnchor = tester.getTopLeft(profileTitle);
        _expectSameAnchor(dashboardAnchor, profileAnchor, 'Dashboard');
        expect(profileAnchor.dx, closeTo(profileContext.ui(24), 0.1));
        expect(profileAnchor.dy, closeTo(profileContext.ui(28), 0.1));

        for (final page in [
          (RoutePaths.survey, 'Survei Harian'),
          (RoutePaths.history, 'Riwayat Pemeriksaan'),
        ]) {
          await _go(tester, container, page.$1);
          _expectSameAnchor(
            tester.getTopLeft(_headerTitle(page.$2)),
            dashboardAnchor,
            page.$2,
          );
          expect(find.byType(AppBackButton), findsNothing);
        }

        await _go(tester, container, RoutePaths.personalization);
        final titleAnchor = tester.getTopLeft(
          _headerTitle('Personalisasi Profil'),
        );
        final iconAnchor = tester.getTopLeft(_backIcon);
        expect(titleAnchor.dy, closeTo(dashboardAnchor.dy, 0.1));
        expect(iconAnchor.dy, closeTo(dashboardAnchor.dy, 0.1));

        for (final page in [
          (RoutePaths.editProfile, 'Edit Profil'),
          (RoutePaths.preferences, 'Preferensi'),
          (RoutePaths.help, 'Bantuan'),
          (RoutePaths.about, 'Tentang Aplikasi'),
          (RoutePaths.resultFor('4'), 'Hasil Prediksi'),
          (
            '${RoutePaths.resultFor('4')}/recommendations',
            'Rekomendasi untuk Kamu',
          ),
          // Unavailable results must use the same header as loaded results.
          (RoutePaths.resultFor('missing-assessment'), 'Hasil Prediksi'),
        ]) {
          await _go(tester, container, page.$1);
          _expectSameAnchor(
            tester.getTopLeft(_headerTitle(page.$2)),
            titleAnchor,
            page.$2,
          );
          _expectSameAnchor(
            tester.getTopLeft(_backIcon),
            iconAnchor,
            '${page.$2} back icon',
          );
          final touchArea = tester.getRect(_backButton);
          expect(touchArea.width, greaterThanOrEqualTo(48));
          expect(touchArea.height, greaterThanOrEqualTo(48));
        }

        await _go(
          tester,
          container,
          RoutePaths.questionsFor(SurveyOrigin.surveyTab),
        );
        _expectSameAnchor(
          tester.getTopLeft(_backIcon),
          iconAnchor,
          'Survey question back icon',
        );

        // The extra touch space above the icon remains usable after alignment.
        final touchArea = tester.getRect(_backButton);
        expect(touchArea.width, greaterThanOrEqualTo(48));
        expect(touchArea.height, greaterThanOrEqualTo(48));
        await tester.tapAt(Offset(touchArea.center.dx, touchArea.top + 1));
        await tester.pumpAndSettle();
        expect(_headerTitle('Survei Harian'), findsOneWidget);
        expect(find.byType(AppBackButton), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
