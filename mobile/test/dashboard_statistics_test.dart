import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/assessment/di/assessment_providers.dart';
import 'package:mobile/features/assessment/domain/entities/assessment.dart';
import 'package:mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:mobile/features/dashboard/presentation/widgets/risk_statistics_card.dart';

void main() {
  test(
    'statistics deduplicate session results and sort by assessment date',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(assessmentSessionCacheProvider.notifier).state = {
        '4': Assessment(
          id: '4',
          riskLevel: RiskLevel.tinggi,
          takenAt: DateTime(2027),
        ),
      };
      final items = container.read(dashboardAssessmentsProvider);
      expect(items.length, 4);
      expect(items.first.id, '4');
      expect(items.first.riskLevel, RiskLevel.tinggi);
      expect(items.first.isExample, isFalse);
      expect(container.read(latestAssessmentProvider), same(items.first));
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'statistics render narrow and wide with large text, dark=$dark',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.view.devicePixelRatio = 1;
        for (final width in [320.0, 1024.0]) {
          tester.view.physicalSize = Size(width, 1366);
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 1366),
                  textScaler: const TextScaler.linear(2),
                ),
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: RiskStatisticsCard(
                        assessments: container.read(
                          dashboardAssessmentsProvider,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 300));
          expect(tester.takeException(), isNull);
          expect(find.text('4 asesmen tercatat'), findsOneWidget);
          expect(find.text('Pratinjau dengan data contoh'), findsOneWidget);
        }
      },
    );
  }

  testWidgets('empty statistics invite a first assessment without a chart', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: RiskStatisticsCard(assessments: [])),
      ),
    );
    expect(
      find.text('Statistik akan muncul setelah asesmen pertamamu.'),
      findsOneWidget,
    );
    expect(find.text('Pratinjau dengan data contoh'), findsNothing);
  });
}
