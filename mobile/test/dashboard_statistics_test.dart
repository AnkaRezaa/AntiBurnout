import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/assessment/di/assessment_providers.dart';
import 'package:mobile/features/assessment/domain/entities/assessment.dart';
import 'package:mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:mobile/features/dashboard/presentation/widgets/risk_statistics_card.dart';
import 'package:mobile/features/dashboard/presentation/widgets/weekly_risk_chart.dart';
import 'package:mobile/features/history/presentation/controllers/history_repository.dart';
import 'package:mobile/features/history/presentation/widgets/assessment_history_item.dart';

final _now = DateTime(2026, 10, 16, 12);

List<Assessment> _examples() => [
  Assessment(
    id: '4',
    riskLevel: RiskLevel.sedang,
    takenAt: DateTime(2026, 10, 15, 20, 15),
    isExample: true,
  ),
  Assessment(
    id: '3',
    riskLevel: RiskLevel.rendah,
    takenAt: DateTime(2026, 10, 15, 9, 40),
    isExample: true,
  ),
  Assessment(
    id: '2',
    riskLevel: RiskLevel.sedang,
    takenAt: DateTime(2026, 10, 13, 21, 10),
    isExample: true,
  ),
  Assessment(
    id: '1',
    riskLevel: RiskLevel.tinggi,
    takenAt: DateTime(2026, 10, 10, 18, 25),
    isExample: true,
  ),
];

Future<void> _pumpCard(
  WidgetTester tester, {
  required List<Assessment> assessments,
  double width = 390,
  double textScale = 1,
  bool dark = false,
  int revision = 0,
}) async {
  tester.view.physicalSize = Size(width, 1366);
  await tester.pumpWidget(
    MaterialApp(
      title: 'Dashboard $revision',
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 1366),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: RiskStatisticsCard(assessments: assessments, now: _now),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _prepareView(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Finder _day(int day) => find.byKey(
  ValueKey('risk-day-${DateTime(2026, 10, day).toIso8601String()}'),
);

Finder _survey(String id) => find.byKey(ValueKey('risk-survey-$id'));

Finder get _horizontalChart =>
    find.byKey(const PageStorageKey('weekly-risk-chart-scroll'));

ScrollableState _horizontalState(WidgetTester tester) =>
    tester.state<ScrollableState>(
      find.descendant(of: _horizontalChart, matching: find.byType(Scrollable)),
    );

void _expectTotalCounts(
  WidgetTester tester, {
  required int rendah,
  required int sedang,
  required int tinggi,
}) {
  final expected = {
    RiskLevel.rendah: rendah,
    RiskLevel.sedang: sedang,
    RiskLevel.tinggi: tinggi,
  };
  for (final entry in expected.entries) {
    expect(
      tester
          .widget<Text>(find.byKey(ValueKey('risk-total-${entry.key.name}')))
          .data,
      '${entry.value}',
    );
  }
}

void main() {
  test(
    'statistics deduplicate session results and sort by assessment date',
    () {
      final container = ProviderContainer(
        overrides: [
          assessmentFixtureProvider.overrideWithValue([
            for (final assessment in _examples())
              AssessmentHistoryItem(
                id: assessment.id,
                riskLevel: assessment.riskLevel,
                takenAt: assessment.takenAt,
              ),
          ]),
        ],
      );
      addTearDown(container.dispose);
      container.read(assessmentSessionCacheProvider.notifier).state = {
        '4': Assessment(
          id: '4',
          riskLevel: RiskLevel.tinggi,
          takenAt: DateTime(2026, 10, 16, 10),
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
      'all-time summary and weekly chart render narrow and wide with large text, dark=$dark',
      (tester) async {
        _prepareView(tester);
        for (final width in [320.0, 1024.0]) {
          await _pumpCard(
            tester,
            assessments: _examples(),
            width: width,
            textScale: 2,
            dark: dark,
          );
          expect(tester.takeException(), isNull);
          expect(find.text('4 asesmen secara keseluruhan'), findsOneWidget);
          expect(find.text('4 asesmen dalam 7 hari terakhir'), findsOneWidget);
          expect(find.text('Pratinjau dengan data contoh'), findsOneWidget);
          expect(find.text('Ringkasan seluruh riwayat survei'), findsOneWidget);
          expect(find.text('Grafik 7 hari terakhir'), findsOneWidget);
          _expectTotalCounts(tester, rendah: 1, sedang: 2, tinggi: 1);
          for (var day = 10; day <= 16; day++) {
            expect(_day(day), findsOneWidget);
          }
        }
      },
    );
  }

  testWidgets('all-time counts retain records outside the weekly chart', (
    tester,
  ) async {
    _prepareView(tester);
    await _pumpCard(
      tester,
      assessments: [
        ..._examples(),
        Assessment(
          id: 'old',
          riskLevel: RiskLevel.tinggi,
          takenAt: DateTime(2026, 10, 9, 23, 59),
        ),
        Assessment(
          id: 'future',
          riskLevel: RiskLevel.tinggi,
          takenAt: DateTime(2026, 10, 17),
        ),
      ],
    );
    expect(find.text('6 asesmen secara keseluruhan'), findsOneWidget);
    expect(find.text('4 asesmen dalam 7 hari terakhir'), findsOneWidget);
    _expectTotalCounts(tester, rendah: 1, sedang: 2, tinggi: 3);
    expect(find.text('Termasuk data contoh'), findsOneWidget);
    expect(_survey('old'), findsNothing);
    expect(_survey('future'), findsNothing);
    final chart = tester.widget<WeeklyRiskChart>(find.byType(WeeklyRiskChart));
    expect(chart.days, hasLength(7));
    expect(chart.days.expand((day) => day.assessments).map((item) => item.id), [
      '1',
      '2',
      '3',
      '4',
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'newest dates and same-day results start on the left with tooltips',
    (tester) async {
      _prepareView(tester);
      await _pumpCard(tester, assessments: _examples(), width: 320);
      await Scrollable.ensureVisible(
        tester.element(_horizontalChart),
        alignment: .5,
      );
      await tester.pumpAndSettle();
      expect(_horizontalState(tester).position.pixels, 0);
      final viewport = tester.getRect(_horizontalChart);
      final today = tester.getRect(_day(16));
      expect(today.left, greaterThanOrEqualTo(viewport.left));
      expect(today.right, lessThanOrEqualTo(viewport.right));
      expect(
        tester.getTopLeft(_day(16)).dx,
        lessThan(tester.getTopLeft(_day(15)).dx),
      );
      expect(
        tester.getTopLeft(_day(15)).dx,
        lessThan(tester.getTopLeft(_day(10)).dx),
      );
      final yesterday = _day(15);
      expect(
        find.descendant(of: yesterday, matching: find.text('2 survei')),
        findsOneWidget,
      );
      for (final id in ['3', '4']) {
        expect(
          find.descendant(of: yesterday, matching: _survey(id)),
          findsOneWidget,
        );
      }
      expect(
        tester.getTopLeft(_survey('4')).dx,
        lessThan(tester.getTopLeft(_survey('3')).dx),
      );
      await Scrollable.ensureVisible(tester.element(_day(10)), alignment: 1);
      await tester.pumpAndSettle();
      expect(_horizontalState(tester).position.pixels, greaterThan(0));
      final oldest = tester.getRect(_day(10));
      expect(oldest.left, greaterThanOrEqualTo(viewport.left - .1));
      expect(oldest.right, lessThanOrEqualTo(viewport.right + .1));
      await Scrollable.ensureVisible(
        tester.element(_survey('4')),
        alignment: .5,
      );
      await tester.pumpAndSettle();
      await tester.tap(_survey('4'));
      await tester.pumpAndSettle();
      expect(find.text('Sedang · 20:15'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a date retains every survey instead of capping the chart at seven',
    (tester) async {
      _prepareView(tester);
      final assessments = [
        for (var index = 8; index >= 0; index--)
          Assessment(
            id: 'same-day-$index',
            riskLevel: RiskLevel.values[index % RiskLevel.values.length],
            takenAt: DateTime(2026, 10, 15, 8 + index),
          ),
      ];
      await _pumpCard(tester, assessments: assessments);
      expect(find.text('9 asesmen secara keseluruhan'), findsOneWidget);
      expect(find.text('9 asesmen dalam 7 hari terakhir'), findsOneWidget);
      final day = _day(15);
      expect(
        find.descendant(of: day, matching: find.text('9 survei')),
        findsOneWidget,
      );
      for (var index = 0; index < 9; index++) {
        expect(
          find.descendant(of: day, matching: _survey('same-day-$index')),
          findsOneWidget,
        );
      }
      final chart = tester.widget<WeeklyRiskChart>(
        find.byType(WeeklyRiskChart),
      );
      expect(
        chart.days
            .singleWhere((day) => day.date.day == 15)
            .assessments
            .map((assessment) => assessment.id),
        [for (var index = 0; index < 9; index++) 'same-day-$index'],
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('horizontal chart keeps its offset on rebuild and resize', (
    tester,
  ) async {
    _prepareView(tester);
    await _pumpCard(tester, assessments: _examples(), width: 320);
    await Scrollable.ensureVisible(
      tester.element(_horizontalChart),
      alignment: .5,
    );
    await tester.pumpAndSettle();
    await tester.drag(_horizontalChart, const Offset(-140, 0));
    await tester.pumpAndSettle();
    final position = _horizontalState(tester).position;
    final offset = position.pixels;
    expect(offset, greaterThan(0));
    await _pumpCard(tester, assessments: _examples(), width: 320, revision: 1);
    expect(_horizontalState(tester).position, same(position));
    expect(_horizontalState(tester).position.pixels, closeTo(offset, .1));
    await _pumpCard(tester, assessments: _examples(), width: 480, revision: 2);
    expect(_horizontalState(tester).position, same(position));
    expect(_horizontalState(tester).position.pixels, closeTo(offset, .1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty week preserves older examples in the all-time summary', (
    tester,
  ) async {
    _prepareView(tester);
    await _pumpCard(
      tester,
      assessments: [
        Assessment(
          id: 'old-example',
          riskLevel: RiskLevel.tinggi,
          takenAt: DateTime(2026, 10, 1),
          isExample: true,
        ),
      ],
    );
    expect(find.text('1 asesmen secara keseluruhan'), findsOneWidget);
    expect(find.text('0 asesmen dalam 7 hari terakhir'), findsOneWidget);
    _expectTotalCounts(tester, rendah: 0, sedang: 0, tinggi: 1);
    expect(
      find.text('Belum ada survei dalam 7 hari terakhir.'),
      findsOneWidget,
    );
    expect(find.text('Pratinjau dengan data contoh'), findsOneWidget);
    expect(find.text('Termasuk data contoh'), findsNothing);
    expect(find.text('0 survei'), findsNWidgets(7));
    for (var day = 10; day <= 16; day++) {
      expect(_day(day), findsOneWidget);
    }
    expect(_survey('old-example'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('older example marker remains beside newer real weekly data', (
    tester,
  ) async {
    _prepareView(tester);
    await _pumpCard(
      tester,
      assessments: [
        Assessment(
          id: 'older-example',
          riskLevel: RiskLevel.tinggi,
          takenAt: DateTime(2026, 10, 1),
          isExample: true,
        ),
        Assessment(
          id: 'current-result',
          riskLevel: RiskLevel.rendah,
          takenAt: DateTime(2026, 10, 16, 9),
        ),
      ],
    );

    expect(find.text('2 asesmen secara keseluruhan'), findsOneWidget);
    expect(find.text('1 asesmen dalam 7 hari terakhir'), findsOneWidget);
    _expectTotalCounts(tester, rendah: 1, sedang: 0, tinggi: 1);
    expect(find.text('Termasuk data contoh'), findsOneWidget);
    expect(find.text('Pratinjau dengan data contoh'), findsNothing);
    expect(_survey('older-example'), findsNothing);
    expect(_survey('current-result'), findsOneWidget);
    final chart = tester.widget<WeeklyRiskChart>(find.byType(WeeklyRiskChart));
    expect(
      chart.days.expand((day) => day.assessments).single.id,
      'current-result',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty history has zero totals and seven empty chart dates', (
    tester,
  ) async {
    _prepareView(tester);
    await _pumpCard(tester, assessments: []);

    expect(find.text('0 asesmen secara keseluruhan'), findsOneWidget);
    expect(find.text('0 asesmen dalam 7 hari terakhir'), findsOneWidget);
    _expectTotalCounts(tester, rendah: 0, sedang: 0, tinggi: 0);
    expect(find.text('Pratinjau dengan data contoh'), findsNothing);
    expect(find.text('Termasuk data contoh'), findsNothing);
    expect(find.text('0 survei'), findsNWidgets(7));
    expect(
      find.text('Belum ada survei dalam 7 hari terakhir.'),
      findsOneWidget,
    );
    for (var day = 10; day <= 16; day++) {
      expect(_day(day), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
