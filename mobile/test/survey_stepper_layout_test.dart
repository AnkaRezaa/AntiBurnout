import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/survey/data/fixtures/survey_questions.dart';
import 'package:mobile/features/survey/presentation/controllers/survey_state.dart';
import 'package:mobile/features/survey/presentation/widgets/survey_stepper.dart';

void main() {
  for (final viewport in [const Size(390, 844), const Size(430, 1000)]) {
    testWidgets('survey titles keep the same gap below progress at $viewport', (
      tester,
    ) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SurveyStepper(
              state: SurveyState(
                questions: surveyQuestions,
                answers: {
                  for (final question in surveyQuestions)
                    question.id:
                        question.initialAnswer ?? question.options.first,
                },
              ),
              onBack: () {},
              onChanged: (id, answer) {},
              onSubmit: () async {},
            ),
            bottomNavigationBar: const SizedBox(height: 72),
          ),
        ),
      );
      await tester.pumpAndSettle();

      double? firstStepGap;
      final total = surveyQuestions.length + 1;
      for (var step = 0; step < total; step++) {
        final title = find.text(
          step < surveyQuestions.length
              ? surveyQuestions[step].label
              : 'Periksa jawabanmu',
        );
        final percentage = find.text('${((step + 1) / total * 100).round()}%');
        final gap =
            tester.getTopLeft(title).dy - tester.getBottomLeft(percentage).dy;
        firstStepGap ??= gap;
        expect(
          gap,
          closeTo(firstStepGap, 0.5),
          reason: 'Step ${step + 1} should align like the first question.',
        );
        expect(tester.takeException(), isNull);
        if (step < surveyQuestions.length) {
          final next = find.text('Lanjut');
          await tester.ensureVisible(next);
          await tester.tap(next);
          await tester.pumpAndSettle();
        }
      }
    });
  }
}
