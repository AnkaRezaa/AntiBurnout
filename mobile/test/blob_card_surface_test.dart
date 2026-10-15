import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/theme/assessment_colors.dart';
import 'package:mobile/features/dashboard/presentation/widgets/motivation_card.dart';
import 'package:mobile/features/profile/presentation/pages/about_page.dart';
import 'package:mobile/features/recommendations/presentation/widgets/recommendation_card.dart';
import 'package:mobile/features/survey/presentation/pages/survey_intro_page.dart';

BoxDecoration _cardAbove(WidgetTester tester, Finder content) {
  BoxDecoration? decoration;
  tester.element(content).visitAncestorElements((element) {
    final widget = element.widget;
    if (widget is Container && widget.decoration is BoxDecoration) {
      final candidate = widget.decoration! as BoxDecoration;
      if (candidate.color != null || candidate.gradient != null) {
        decoration = candidate;
        return false;
      }
    }
    return true;
  });
  expect(
    decoration,
    isNotNull,
    reason: 'The content must have a card surface.',
  );
  return decoration!;
}

void _expectOpaque(BoxDecoration decoration, String card) {
  final colors = decoration.gradient?.colors ?? [decoration.color!];
  for (final color in colors) {
    expect(
      color.a,
      1,
      reason: '$card must hide decorative blobs at every part of its fill.',
    );
  }
}

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'colored cards hide background blobs (${dark ? 'dark' : 'light'})',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        Future<void> show(Widget page) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              home: page,
            ),
          );
          await tester.pumpAndSettle();
        }

        await show(const SurveyIntroPage());
        _expectOpaque(
          _cardAbove(tester, find.text('Bagaimana harimu?')),
          'Survey introduction hero',
        );
        _expectOpaque(
          _cardAbove(
            tester,
            find.textContaining('Tidak ada jawaban benar atau salah.'),
          ),
          'Survey introduction hint',
        );

        await show(AboutPage(onBack: () {}));
        _expectOpaque(
          _cardAbove(tester, find.text('Kenali dirimu. Jaga keseimbanganmu.')),
          'About hero',
        );
        _expectOpaque(
          _cardAbove(
            tester,
            find.textContaining('Hasil asesmen bukan diagnosis medis.'),
          ),
          'Profile information card',
        );

        // Existing category cards must also remain solid when an interior blob
        // happens to sit behind them, in both app themes.
        await show(
          const Scaffold(
            body: Column(
              children: [
                MotivationCard(quote: 'Motivasi contoh'),
                RecommendationCard(
                  icon: Icons.bedtime_outlined,
                  backgroundColor: AssessmentColors.sleepTint,
                  title: 'Rekomendasi contoh',
                  body: 'Isi rekomendasi',
                ),
              ],
            ),
          ),
        );
        _expectOpaque(
          _cardAbove(tester, find.text('Motivasi contoh')),
          'Dashboard motivation card',
        );
        _expectOpaque(
          _cardAbove(tester, find.text('Rekomendasi contoh')),
          'Recommendation card',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
