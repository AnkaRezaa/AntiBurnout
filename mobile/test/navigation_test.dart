import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/router/app_router.dart';
import 'package:mobile/app/router/route_paths.dart';
import 'package:mobile/features/assessment/di/assessment_providers.dart';
import 'package:mobile/features/assessment/domain/entities/assessment.dart';
import 'package:mobile/features/assessment/domain/repositories/assessment_repository.dart';
import 'package:mobile/features/auth/domain/entities/auth_user.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mobile/features/auth/presentation/controllers/auth_state.dart';
import 'package:mobile/features/history/presentation/controllers/history_controller.dart';
import 'package:mobile/features/history/presentation/controllers/history_repository.dart';
import 'package:mobile/features/history/presentation/controllers/history_state.dart';
import 'package:mobile/features/history/presentation/widgets/assessment_history_item.dart';
import 'package:mobile/features/history/presentation/widgets/assessment_history_tile.dart';
import 'package:mobile/features/recommendations/presentation/pages/recommendation_page.dart';
import 'package:mobile/features/results/presentation/pages/result_page.dart';
import 'package:mobile/features/survey/di/survey_providers.dart';
import 'package:mobile/features/survey/data/repositories/in_memory_survey_repository.dart';
import 'package:mobile/features/survey/domain/entities/survey_question.dart';
import 'package:mobile/features/survey/domain/repositories/survey_repository.dart';
import 'package:mobile/features/survey/presentation/pages/survey_question_page.dart';

class _Authenticated extends AuthController {
  @override
  AuthState build() => const AuthState.authenticated(
    AuthUser(id: 'test', email: 'test@example.com', name: 'Pengguna Uji'),
  );

  void switchUser(String id) => state = AuthState.authenticated(
    AuthUser(id: id, email: '$id@example.com', name: id),
  );
}

// These questions and predictions exist only inside this test repository.
class _Questions implements SurveyRepository {
  @override
  Future<List<SurveyQuestion>> getQuestions() async => const [
    SurveyQuestion(id: 'test-question', label: 'Pertanyaan pengujian'),
  ];
}

class _Assessments implements AssessmentRepository {
  int submissions = 0;
  Map<String, String>? lastAnswers;
  bool fail = false;
  Completer<void>? pending;
  final Map<String, Assessment> items = {
    'A': Assessment(
      id: 'A',
      riskLevel: RiskLevel.rendah,
      takenAt: DateTime(2026, 9, 10),
      modelFactors: const [AssessmentFactor(label: 'Faktor dari layanan A')],
      answerSummary: const [
        AssessmentAnswerSummary(label: 'Tidur', value: 'Jawaban A'),
      ],
    ),
    'B': Assessment(
      id: 'B',
      riskLevel: RiskLevel.tinggi,
      takenAt: DateTime(2026, 9, 18),
    ),
  };

  @override
  Future<Assessment?> getById(String id) async => items[id];

  @override
  Future<Assessment> submit(Map<String, String> answers) async {
    submissions++;
    lastAnswers = Map.of(answers);
    await pending?.future;
    if (fail) throw Exception('Test service failed');
    // The UI must also work before getById is updated by the server.
    return Assessment(
      id: 'submitted-$submissions',
      riskLevel: RiskLevel.sedang,
      takenAt: DateTime(2026, 10, 15),
    );
  }
}

Future<ProviderContainer> _start(
  WidgetTester tester, {
  _Assessments? repository,
  bool questions = true,
  bool defaultQuestions = false,
  List<AssessmentHistoryItem>? history,
}) async {
  final container = ProviderContainer(
    overrides: [
      authControllerProvider.overrideWith(_Authenticated.new),
      if (repository != null)
        assessmentRepositoryProvider.overrideWithValue(repository),
      if (!defaultQuestions)
        surveyRepositoryProvider.overrideWithValue(
          questions
              ? _Questions()
              : const InMemorySurveyRepository(questions: []),
        ),
      if (history != null) assessmentFixtureProvider.overrideWithValue(history),
    ],
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
  await tester.pump();
  final target = find.text(label).last;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _back(WidgetTester tester, bool android) async {
  if (android) {
    await tester.binding.handlePopRoute();
  } else {
    final button = find
        .byWidgetPredicate(
          (widget) =>
              widget is IconButton &&
              (widget.tooltip?.startsWith('Kembali') ?? false),
        )
        .last;
    await tester.ensureVisible(button);
    await tester.tap(button);
  }
  await tester.pumpAndSettle();
}

void main() {
  for (final origin in SurveyOrigin.values) {
    testWidgets(
      'main survey UI retains answers, origin and assessment ID (${origin.name})',
      (tester) async {
        final repository = _Assessments();
        final container = await _start(
          tester,
          repository: repository,
          defaultQuestions: true,
        );
        if (origin == SurveyOrigin.dashboard) {
          await _tap(tester, 'Mulai Survei');
        } else {
          await _tab(tester, 'Survei');
        }
        await _tap(tester, 'Mulai Survei');
        expect(find.text('Langkah 1 dari 8'), findsOneWidget);
        await _tap(tester, 'Baik');
        await _tap(tester, 'Lanjut');
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pumpAndSettle();
        await _tab(tester, 'Profil');
        await _tab(tester, 'Survei');
        expect(find.text('Langkah 2 dari 8'), findsOneWidget);
        expect(find.text('6.5'), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Langkah 1 dari 8'), findsOneWidget);
        await _tap(tester, 'Lanjut');
        expect(find.text('6.5'), findsOneWidget);
        for (var i = 0; i < 6; i++) {
          await _tap(tester, 'Lanjut');
        }
        expect(find.text('Langkah 8 dari 8'), findsOneWidget);
        expect(find.text('6.5 jam'), findsOneWidget);
        await _tap(tester, 'Kirim & lihat hasil');
        expect(repository.lastAnswers, {
          'sleep_quality': 'Baik',
          'screen_hours': '6.5',
          'sleep_hours': '7.0',
          'coffee_cups': '2',
          'activity_load': 'Sedang',
          'meditation_minutes': '10',
          'mood_rating': '65',
        });
        expect(
          tester.widget<ResultPage>(find.byType(ResultPage)).assessmentId,
          'submitted-1',
        );
        await _back(tester, origin == SurveyOrigin.dashboard);
        expect(
          container
              .read(appRouterProvider)
              .routeInformationProvider
              .value
              .uri
              .path,
          origin == SurveyOrigin.dashboard
              ? RoutePaths.home
              : RoutePaths.survey,
        );
        expect(repository.submissions, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'main survey validates custom minutes and synchronizes preset input',
    (tester) async {
      await _start(tester, repository: _Assessments(), defaultQuestions: true);
      await _tab(tester, 'Survei');
      await _tap(tester, 'Mulai Survei');
      await _tap(tester, 'Baik');
      for (var i = 0; i < 5; i++) {
        await _tap(tester, 'Lanjut');
      }
      expect(find.text('Langkah 6 dari 8'), findsOneWidget);
      final minutes = find.byKey(
        const ValueKey('survey-answer-meditation_minutes'),
      );
      await tester.enterText(minutes, '-1');
      await _tap(tester, 'Lanjut');
      expect(find.text('Langkah 6 dari 8'), findsOneWidget);
      await _tap(tester, '15');
      expect(tester.widget<TextFormField>(minutes).controller!.text, '15');
      await _tap(tester, 'Lanjut');
      expect(find.text('Langkah 7 dari 8'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'main survey works on small screens with large text and reports missing service',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _start(tester, defaultQuestions: true);
      await _tab(tester, 'Survei');
      expect(tester.takeException(), isNull);
      await _tap(tester, 'Mulai Survei');
      await _tap(tester, 'Baik');
      for (var i = 0; i < 7; i++) {
        expect(tester.takeException(), isNull);
        await _tap(tester, 'Lanjut');
      }
      expect(find.text('Langkah 8 dari 8'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _tap(tester, 'Kirim & lihat hasil');
      expect(
        find.text('Layanan asesmen belum tersedia. Jawaban belum dikirim.'),
        findsOneWidget,
      );
      expect(find.byType(ResultPage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Android back at survey intro switches to dashboard', (
    tester,
  ) async {
    await _start(tester);
    await _tab(tester, 'Survei');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      0,
    );
    await _tab(tester, 'Survei');
    expect(find.text('Survei Harian'), findsOneWidget);
  });
  testWidgets(
    'dashboard avatar opens profile; navbar has four tabs without results',
    (tester) async {
      await _start(tester);
      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.items.map((item) => item.label), [
        'Beranda',
        'Survei',
        'Riwayat',
        'Profil',
      ]);
      await tester.tap(find.byTooltip('Buka profil'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        3,
      );
      expect(find.text('Personalisasi Profil'), findsOneWidget);
    },
  );

  for (final android in [false, true]) {
    testWidgets(
      'dashboard latest detail opens exact assessment in History and backs to list (${android ? 'Android' : 'UI'})',
      (tester) async {
        final repository = _Assessments();
        final container = await _start(
          tester,
          repository: repository,
          history: [
            for (final item in repository.items.values)
              AssessmentHistoryItem(
                id: item.id,
                riskLevel: item.riskLevel,
                takenAt: item.takenAt,
              ),
          ],
        );
        // A is first in the fixture; B is the latest by its assessment date.
        await _tap(tester, 'Lihat Detail ›');
        expect(
          tester.widget<ResultPage>(find.byType(ResultPage)).assessmentId,
          'B',
        );
        expect(
          tester
              .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
              .currentIndex,
          2,
        );
        await _tap(tester, 'Lihat Rekomendasi');
        expect(
          tester
              .widget<RecommendationPage>(find.byType(RecommendationPage))
              .assessmentId,
          'B',
        );
        await _back(tester, android);
        expect(
          tester.widget<ResultPage>(find.byType(ResultPage)).assessmentId,
          'B',
        );
        await _back(tester, android);
        expect(find.text('Riwayat Pemeriksaan'), findsOneWidget);
        expect(find.byType(ResultPage), findsNothing);
        expect(
          container
              .read(appRouterProvider)
              .routeInformationProvider
              .value
              .uri
              .path,
          RoutePaths.history,
        );
        expect(
          tester
              .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
              .currentIndex,
          2,
        );
        expect(repository.submissions, 0);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'dashboard latest detail replaces an older retained History detail',
    (tester) async {
      final repository = _Assessments();
      await _start(
        tester,
        repository: repository,
        history: [
          for (final item in repository.items.values)
            AssessmentHistoryItem(
              id: item.id,
              riskLevel: item.riskLevel,
              takenAt: item.takenAt,
            ),
        ],
      );
      await _tab(tester, 'Riwayat');
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is AssessmentHistoryTile && widget.item.id == 'A',
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<ResultPage>(find.byType(ResultPage)).assessmentId,
        'A',
      );
      await _tab(tester, 'Beranda');
      await _tap(tester, 'Lihat Detail ›');
      expect(
        tester.widget<ResultPage>(find.byType(ResultPage)).assessmentId,
        'B',
      );
      await _tab(tester, 'Beranda');
      await _tab(tester, 'Riwayat');
      expect(
        tester.widget<ResultPage>(find.byType(ResultPage)).assessmentId,
        'B',
      );
      await _back(tester, false);
      expect(find.text('Riwayat Pemeriksaan'), findsOneWidget);
      expect(find.byType(ResultPage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'dashboard latest detail follows a newer session assessment absent from repository',
    (tester) async {
      final repository = _Assessments();
      final container = await _start(
        tester,
        repository: repository,
        history: [
          for (final item in repository.items.values)
            AssessmentHistoryItem(
              id: item.id,
              riskLevel: item.riskLevel,
              takenAt: item.takenAt,
            ),
        ],
      );
      container.read(assessmentSessionCacheProvider.notifier).state = {
        'session-latest': Assessment(
          id: 'session-latest',
          riskLevel: RiskLevel.sedang,
          takenAt: DateTime(2026, 10, 16),
          modelFactors: const [AssessmentFactor(label: 'Faktor dari sesi')],
        ),
      };
      await tester.pumpAndSettle();
      await _tap(tester, 'Lihat Detail ›');
      expect(
        tester.widget<ResultPage>(find.byType(ResultPage)).assessmentId,
        'session-latest',
      );
      expect(find.text('Faktor dari sesi'), findsOneWidget);
      expect(repository.items.containsKey('session-latest'), isFalse);
      await _tap(tester, 'Lihat Rekomendasi');
      expect(
        tester
            .widget<RecommendationPage>(find.byType(RecommendationPage))
            .assessmentId,
        'session-latest',
      );
      await _back(tester, true);
      await _back(tester, false);
      expect(find.text('Riwayat Pemeriksaan'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AssessmentHistoryTile &&
              widget.item.id == 'session-latest',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'dashboard without assessments does not expose a result shortcut',
    (tester) async {
      await _start(tester, history: []);
      expect(find.text('Belum ada asesmen'), findsOneWidget);
      expect(find.text('Lihat Detail ›'), findsNothing);
      expect(find.text('Riwayat Saya'), findsOneWidget);
      await _tap(tester, 'Riwayat Saya');
      expect(find.text('Riwayat Pemeriksaan'), findsOneWidget);
      expect(find.byType(ResultPage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final android in [false, true]) {
    testWidgets(
      'history A, filters and scroll survive tabs and detail back (${android ? 'Android' : 'UI'})',
      (tester) async {
        final repository = _Assessments();
        final history = List.generate(
          24,
          (index) => AssessmentHistoryItem(
            id: index == 18 ? 'A' : 'B-$index',
            riskLevel: RiskLevel.rendah,
            takenAt: DateTime(2026, 9, 30 - index),
          ),
        );
        final container = await _start(
          tester,
          repository: repository,
          history: history,
        );
        await _tab(tester, 'Riwayat');
        await tester.enterText(find.byType(TextField), 'rendah');
        await tester.tap(find.text('Rendah').first);
        await tester.pumpAndSettle();
        final list = find.byType(ListView).last;
        final tileA = find.byWidgetPredicate(
          (widget) => widget is AssessmentHistoryTile && widget.item.id == 'A',
        );
        await tester.scrollUntilVisible(
          tileA,
          300,
          scrollable: find
              .descendant(of: list, matching: find.byType(Scrollable))
              .first,
        );
        final scroll = tester.state<ScrollableState>(
          find.descendant(of: list, matching: find.byType(Scrollable)).first,
        );
        final offset = scroll.position.pixels;
        expect(offset, greaterThan(0));
        await tester.tap(tileA);
        await tester.pumpAndSettle();
        expect(
          tester.widget<ResultPage>(find.byType(ResultPage)).assessmentId,
          'A',
        );
        expect(find.text('Faktor dari layanan A'), findsOneWidget);
        expect(find.textContaining('Jawaban A'), findsOneWidget);
        expect(find.textContaining('bukan diagnosis medis'), findsOneWidget);
        await _tab(tester, 'Beranda');
        await _tab(tester, 'Riwayat');
        expect(
          tester.widget<ResultPage>(find.byType(ResultPage)).assessmentId,
          'A',
        );
        expect(
          tester
              .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
              .currentIndex,
          2,
        );
        await _tap(tester, 'Lihat Rekomendasi');
        expect(find.text('Latih Relaksasi'), findsOneWidget);
        await _tab(tester, 'Beranda');
        await _tab(tester, 'Riwayat');
        expect(find.text('Rekomendasi untuk Kamu'), findsOneWidget);
        await _back(tester, android);
        expect(find.byType(ResultPage), findsOneWidget);
        await _back(tester, android);
        expect(find.text('Riwayat Pemeriksaan'), findsOneWidget);
        expect(container.read(historyControllerProvider).query, 'rendah');
        expect(
          container.read(historyControllerProvider).filter,
          HistoryFilter.rendah,
        );
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller?.text ??
              tester
                  .state<EditableTextState>(find.byType(EditableText))
                  .widget
                  .controller
                  .text,
          'rendah',
        );
        expect(scroll.position.pixels, closeTo(offset, 1));
        expect(tester.takeException(), isNull);
      },
    );

    for (final origin in SurveyOrigin.values) {
      testWidgets(
        'successful submit retains ${origin.name} origin and exact ID (${android ? 'Android' : 'UI'})',
        (tester) async {
          final repository = _Assessments();
          final container = await _start(tester, repository: repository);
          if (origin == SurveyOrigin.dashboard) {
            await _tap(tester, 'Mulai Survei');
          } else {
            await _tab(tester, 'Survei');
          }
          await _tap(tester, 'Mulai Survei');
          await tester.enterText(
            find.byKey(const ValueKey('survey-answer-test-question')),
            'Jawaban pengujian',
          );
          // Switching tabs must preserve both the form and its original entry.
          await _tab(tester, 'Profil');
          await _tab(tester, 'Survei');
          await _tap(tester, 'Kirim Jawaban');
          expect(
            tester.widget<ResultPage>(find.byType(ResultPage)).assessmentId,
            'submitted-1',
          );
          expect(
            container
                .read(appRouterProvider)
                .routeInformationProvider
                .value
                .uri,
            Uri.parse(RoutePaths.submittedResultFor(origin, 'submitted-1')),
          );
          expect(find.byType(SurveyQuestionPage), findsNothing);
          expect(
            tester
                .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
                .currentIndex,
            1,
          );
          await _tap(tester, 'Lihat Rekomendasi');
          await _tab(tester, 'Profil');
          await _tab(tester, 'Survei');
          expect(find.text('Rekomendasi untuk Kamu'), findsOneWidget);
          await _back(tester, android);
          expect(find.byType(ResultPage), findsOneWidget);
          await _back(tester, android);
          expect(
            container
                .read(appRouterProvider)
                .routeInformationProvider
                .value
                .uri
                .path,
            origin == SurveyOrigin.dashboard
                ? RoutePaths.home
                : RoutePaths.survey,
          );
          expect(find.byType(SurveyQuestionPage), findsNothing);
          expect(repository.submissions, 1);
          await _tab(tester, 'Survei');
          expect(find.text('Survei Harian'), findsOneWidget);
          expect(find.byType(SurveyQuestionPage), findsNothing);
          expect(find.byType(ResultPage), findsNothing);
          await _tab(tester, 'Riwayat');
          expect(
            container
                .read(historyControllerProvider)
                .items
                .any((item) => item.id == 'submitted-1'),
            isTrue,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'default survey is unavailable; unknown assessment never falls back to latest',
    (tester) async {
      final container = await _start(tester, questions: false);
      await _tab(tester, 'Survei');
      await _tap(tester, 'Mulai Survei');
      expect(find.text('Survei belum tersedia'), findsOneWidget);
      expect(find.text('Kirim Jawaban'), findsNothing);
      container.read(appRouterProvider).go(RoutePaths.resultFor('unknown'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('tidak ditemukan'), findsWidgets);
      expect(find.text('Lihat Rekomendasi'), findsNothing);
    },
  );

  testWidgets('dashboard survey shortcut selects Survey and shares its draft', (
    tester,
  ) async {
    await _start(tester, repository: _Assessments());
    await _tap(tester, 'Mulai Survei');
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      1,
    );
    expect(find.text('Survei Harian'), findsOneWidget);
    await _tab(tester, 'Beranda');
    expect(find.text('Pengguna Uji!'), findsOneWidget);
    expect(find.text('Riwayat Saya'), findsOneWidget);
    await _tap(tester, 'Mulai Survei');
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      1,
    );
    await _tap(tester, 'Mulai Survei');
    final input = find.byKey(const ValueKey('survey-answer-test-question'));
    await tester.enterText(input, 'Draft dari dashboard');
    await _tab(tester, 'Beranda');
    expect(find.byType(SurveyQuestionPage), findsNothing);
    await _tab(tester, 'Survei');
    expect(find.text('Draft dari dashboard'), findsOneWidget);
    await _tab(tester, 'Beranda');
    await _tap(tester, 'Mulai Survei');
    expect(find.byType(SurveyQuestionPage), findsOneWidget);
    expect(find.text('Draft dari dashboard'), findsOneWidget);
  });

  testWidgets(
    'dashboard shortcut resumes a survey-tab draft without changing its origin',
    (tester) async {
      final repository = _Assessments();
      final container = await _start(tester, repository: repository);
      await _tab(tester, 'Survei');
      await _tap(tester, 'Mulai Survei');
      await tester.enterText(
        find.byKey(const ValueKey('survey-answer-test-question')),
        'Draft dari tab',
      );
      await _tab(tester, 'Beranda');
      await _tap(tester, 'Mulai Survei');
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        1,
      );
      expect(find.text('Draft dari tab'), findsOneWidget);
      await _tap(tester, 'Kirim Jawaban');
      await _back(tester, true);
      expect(
        container
            .read(appRouterProvider)
            .routeInformationProvider
            .value
            .uri
            .path,
        RoutePaths.survey,
      );
      expect(find.text('Survei Harian'), findsOneWidget);
      expect(repository.submissions, 1);
    },
  );

  testWidgets(
    'dashboard shortcut preserves the origin of an existing survey intro',
    (tester) async {
      final repository = _Assessments();
      final container = await _start(tester, repository: repository);
      await _tab(tester, 'Survei');
      await _tab(tester, 'Beranda');
      await _tap(tester, 'Mulai Survei');
      await _tap(tester, 'Mulai Survei');
      await tester.enterText(
        find.byKey(const ValueKey('survey-answer-test-question')),
        'Jawaban',
      );
      await _tap(tester, 'Kirim Jawaban');
      await _back(tester, false);
      expect(
        container
            .read(appRouterProvider)
            .routeInformationProvider
            .value
            .uri
            .path,
        RoutePaths.survey,
      );
      expect(find.text('Survei Harian'), findsOneWidget);
    },
  );

  testWidgets(
    'completed flow clears its origin before a new dashboard survey',
    (tester) async {
      final repository = _Assessments();
      final container = await _start(tester, repository: repository);
      // Finish a tab-origin survey, then begin a fresh survey from Dashboard.
      await _tab(tester, 'Survei');
      await _tap(tester, 'Mulai Survei');
      await tester.enterText(
        find.byKey(const ValueKey('survey-answer-test-question')),
        'Survei pertama',
      );
      await _tap(tester, 'Kirim Jawaban');
      await _back(tester, true);
      await _tab(tester, 'Beranda');
      await _tap(tester, 'Mulai Survei');
      await _tap(tester, 'Mulai Survei');
      await tester.enterText(
        find.byKey(const ValueKey('survey-answer-test-question')),
        'Survei kedua',
      );
      await _tap(tester, 'Kirim Jawaban');
      expect(
        tester.widget<ResultPage>(find.byType(ResultPage)).assessmentId,
        'submitted-2',
      );
      await _back(tester, true);
      expect(
        container
            .read(appRouterProvider)
            .routeInformationProvider
            .value
            .uri
            .path,
        RoutePaths.home,
      );
      expect(repository.submissions, 2);
      // Visiting the cached intro is a new tab-origin entry.
      await _tab(tester, 'Survei');
      await _tab(tester, 'Beranda');
      await _tap(tester, 'Mulai Survei');
      await _tap(tester, 'Mulai Survei');
      await tester.enterText(
        find.byKey(const ValueKey('survey-answer-test-question')),
        'Survei ketiga',
      );
      await _tap(tester, 'Kirim Jawaban');
      await _back(tester, true);
      expect(
        container
            .read(appRouterProvider)
            .routeInformationProvider
            .value
            .uri
            .path,
        RoutePaths.survey,
      );
      expect(repository.submissions, 3);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('failed submit stays on form and does not open a result', (
    tester,
  ) async {
    final repository = _Assessments()..fail = true;
    await _start(tester, repository: repository);
    await _tab(tester, 'Survei');
    await _tap(tester, 'Mulai Survei');
    await tester.enterText(
      find.byKey(const ValueKey('survey-answer-test-question')),
      'Jawaban',
    );
    await _tap(tester, 'Kirim Jawaban');
    expect(find.text('Jawaban gagal dikirim. Coba lagi.'), findsOneWidget);
    expect(find.byType(ResultPage), findsNothing);
    expect(repository.submissions, 1);
  });

  testWidgets('in-flight submit blocks duplicates and Android back', (
    tester,
  ) async {
    final pending = Completer<void>();
    final repository = _Assessments()..pending = pending;
    await _start(tester, repository: repository);
    await _tab(tester, 'Survei');
    await _tap(tester, 'Mulai Survei');
    await tester.enterText(
      find.byKey(const ValueKey('survey-answer-test-question')),
      'Jawaban',
    );
    await tester.pump();
    final submit = find.text('Kirim Jawaban');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.tap(submit, warnIfMissed: false);
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(SurveyQuestionPage), findsOneWidget);
    expect(repository.submissions, 1);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byType(ResultPage), findsOneWidget);
    expect(repository.submissions, 1);
  });

  testWidgets(
    'submission finishing after tab switch keeps its dashboard origin',
    (tester) async {
      final pending = Completer<void>();
      final repository = _Assessments()..pending = pending;
      final container = await _start(tester, repository: repository);
      await _tap(tester, 'Mulai Survei');
      await _tap(tester, 'Mulai Survei');
      await tester.enterText(
        find.byKey(const ValueKey('survey-answer-test-question')),
        'Jawaban',
      );
      await tester.pump();
      final submit = find.text('Kirim Jawaban');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();
      await tester.tap(
        find
            .descendant(
              of: find.byType(BottomNavigationBar),
              matching: find.text('Profil'),
            )
            .last,
      );
      await tester.pump(const Duration(milliseconds: 400));
      pending.complete();
      await tester.pumpAndSettle();
      expect(
        container.read(appRouterProvider).routeInformationProvider.value.uri,
        Uri.parse(
          RoutePaths.submittedResultFor(SurveyOrigin.dashboard, 'submitted-1'),
        ),
      );
      await _back(tester, true);
      expect(
        container
            .read(appRouterProvider)
            .routeInformationProvider
            .value
            .uri
            .path,
        RoutePaths.home,
      );
      expect(repository.submissions, 1);
    },
  );

  test('submitted assessment cache resets when the account changes', () {
    final container = ProviderContainer(
      overrides: [authControllerProvider.overrideWith(_Authenticated.new)],
    );
    addTearDown(container.dispose);
    container.read(assessmentSessionCacheProvider.notifier).state = {
      'private': Assessment(
        id: 'private',
        riskLevel: RiskLevel.rendah,
        takenAt: DateTime(2026),
      ),
    };
    (container.read(authControllerProvider.notifier) as _Authenticated)
        .switchUser('next-user');
    expect(container.read(assessmentSessionCacheProvider), isEmpty);
  });

  testWidgets(
    'small viewport and enlarged text can scroll results and guidance',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final container = await _start(tester, repository: _Assessments());
      expect(tester.takeException(), isNull);
      container.read(appRouterProvider).go(RoutePaths.resultFor('A'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _tap(tester, 'Lihat Rekomendasi');
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView).last,
        const Offset(0, -700),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
