import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/router/app_router.dart';
import 'package:mobile/app/router/route_paths.dart';
import 'package:mobile/features/auth/domain/entities/auth_user.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:mobile/features/dashboard/presentation/widgets/latest_assessment_card.dart';
import 'package:mobile/features/history/presentation/widgets/assessment_history_tile.dart';
import 'package:mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile/features/profile/presentation/widgets/personal_data_section.dart';
import 'package:mobile/features/profile/presentation/widgets/profile_subpage_scaffold.dart';
import 'package:mobile/features/recommendations/presentation/widgets/recommendation_card.dart';
import 'package:mobile/features/survey/presentation/controllers/survey_controller.dart';
import 'package:mobile/features/survey/presentation/pages/survey_question_page.dart';
import 'package:mobile/features/survey/presentation/widgets/survey_stepper.dart';
import 'package:mobile/shared/widgets/app_button.dart';

class _Authenticated extends AuthController {
  @override
  AuthState build() => const AuthState.authenticated(
    AuthUser(
      id: 'responsive-test',
      email: 'responsive@example.com',
      name: 'Pengguna',
    ),
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

Finder _button(String label) => find.byWidgetPredicate(
  (widget) => widget is AppButton && widget.label == label,
);

Finder get _profileName => find.descendant(
  of: find.byType(ProfilePage),
  matching: find.text('Pengguna'),
);

void _expectPageWidth(
  WidgetTester tester,
  Finder finder,
  Rect reference,
  String page,
) {
  expect(finder, findsOneWidget, reason: page);
  final actual = tester.getRect(finder);
  expect(
    actual.left,
    closeTo(reference.left, 0.1),
    reason: '$page left margin',
  );
  expect(
    actual.right,
    closeTo(reference.right, 0.1),
    reason: '$page right margin',
  );
}

void main() {
  for (final viewport in [
    const Size(390, 844),
    const Size(1024, 1366),
    const Size(1440, 900),
  ]) {
    testWidgets('page content uses the Profile margins at $viewport', (
      tester,
    ) async {
      final container = await _start(tester, viewport);
      await _go(tester, container, RoutePaths.profile);
      final profileLeft = tester
          .getTopLeft(
            find.descendant(
              of: find.byType(ProfilePage),
              matching: find.text('Profil'),
            ),
          )
          .dx;
      final reference = Rect.fromLTRB(
        profileLeft,
        0,
        viewport.width - profileLeft,
        0,
      );

      await _go(tester, container, RoutePaths.home);
      _expectPageWidth(
        tester,
        find.byType(LatestAssessmentCard),
        reference,
        'Dashboard',
      );
      await _go(tester, container, RoutePaths.survey);
      _expectPageWidth(
        tester,
        _button('Mulai Survei'),
        reference,
        'Survey introduction',
      );
      await _go(
        tester,
        container,
        RoutePaths.questionsFor(SurveyOrigin.surveyTab),
      );
      _expectPageWidth(
        tester,
        find.descendant(
          of: find.byType(SurveyStepper),
          matching: find.byType(LinearProgressIndicator),
        ),
        reference,
        'Survey progress',
      );
      await _go(tester, container, RoutePaths.resultFor('4'));
      _expectPageWidth(
        tester,
        _button('Lihat Rekomendasi'),
        reference,
        'Result',
      );
      await _go(
        tester,
        container,
        '${RoutePaths.resultFor('4')}/recommendations',
      );
      _expectPageWidth(
        tester,
        find.byType(RecommendationCard).first,
        reference,
        'Recommendation',
      );
      await _go(tester, container, RoutePaths.history);
      _expectPageWidth(
        tester,
        find.byType(AssessmentHistoryTile).first,
        reference,
        'History',
      );
      await _go(tester, container, RoutePaths.editProfile);
      _expectPageWidth(
        tester,
        find.byKey(const Key('edit-profile-name')),
        reference,
        'Edit profile',
      );
      for (final location in [
        RoutePaths.preferences,
        RoutePaths.help,
        RoutePaths.about,
      ]) {
        await _go(tester, container, location);
        _expectPageWidth(
          tester,
          find.byType(ProfileInfoCard),
          reference,
          location,
        );
      }
      await _go(tester, container, RoutePaths.personalization);
      _expectPageWidth(
        tester,
        find.byType(PersonalDataSection),
        reference,
        'Personalization',
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'resizing scales history and profile fields and preserves survey draft',
    (tester) async {
      final container = await _start(tester, const Size(390, 844));
      await _go(tester, container, RoutePaths.profile);
      final profileFontBefore = tester
          .widget<Text>(_profileName)
          .style!
          .fontSize!;
      await _go(tester, container, RoutePaths.history);
      final historyTile = find.byType(AssessmentHistoryTile).first;
      final historyTitle = find.descendant(
        of: historyTile,
        matching: find.text('Risiko Burnout'),
      );
      final historyHeightBefore = tester.getSize(historyTile).height;
      final historyFontBefore = tester
          .widget<Text>(historyTitle)
          .style!
          .fontSize!;
      await _go(tester, container, RoutePaths.editProfile);
      final name = find.byKey(const Key('edit-profile-name'));
      final nameInput = find.descendant(
        of: name,
        matching: find.byType(TextField),
      );
      final editFontBefore = tester
          .widget<TextField>(nameInput)
          .style!
          .fontSize!;
      await tester.enterText(name, 'Draft responsif');
      FocusManager.instance.primaryFocus?.unfocus();
      tester.view.physicalSize = const Size(1024, 1366);
      await tester.pumpAndSettle();
      expect(find.text('Draft responsif'), findsOneWidget);
      final editFontAfter = tester
          .widget<TextField>(nameInput)
          .style!
          .fontSize!;
      expect(editFontAfter, greaterThan(editFontBefore));

      await _go(tester, container, RoutePaths.profile);
      final profileFontAfter = tester
          .widget<Text>(_profileName)
          .style!
          .fontSize!;
      final profileRatio = profileFontAfter / profileFontBefore;
      expect(editFontAfter / editFontBefore, closeTo(profileRatio, 0.01));
      await _go(tester, container, RoutePaths.history);
      expect(
        tester.getSize(historyTile).height,
        greaterThan(historyHeightBefore),
      );
      final historyFontAfter = tester
          .widget<Text>(historyTitle)
          .style!
          .fontSize!;
      expect(historyFontAfter / historyFontBefore, closeTo(profileRatio, 0.01));

      await _go(
        tester,
        container,
        RoutePaths.questionsFor(SurveyOrigin.surveyTab),
      );
      final choice = find.text('Baik');
      await tester.ensureVisible(choice);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      final next = _button('Lanjut');
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
      final questionPage = tester.widget<SurveyQuestionPage>(
        find.byType(SurveyQuestionPage),
      );
      tester.view.physicalSize = const Size(1440, 900);
      await tester.pumpAndSettle();
      expect(find.text('Langkah 2 dari 8'), findsOneWidget);
      expect(
        container
            .read(surveyControllerProvider(questionPage.sessionKey))
            .answers['sleep_quality'],
        'Baik',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
