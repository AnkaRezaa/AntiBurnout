import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/assessment/domain/entities/assessment.dart';
import 'package:mobile/features/dashboard/presentation/models/weekly_risk_statistics.dart';

Assessment _assessment(
  String id,
  DateTime takenAt, [
  RiskLevel riskLevel = RiskLevel.rendah,
]) => Assessment(id: id, riskLevel: riskLevel, takenAt: takenAt);

void main() {
  test(
    'keeps all same-day results in time order without a seven-result cap',
    () {
      final input = [
        for (var index = 8; index >= 0; index--)
          _assessment(
            'same-day-$index',
            DateTime(2026, 10, 15, 8 + index),
            RiskLevel.values[index % RiskLevel.values.length],
          ),
        _assessment('today', DateTime(2026, 10, 16, 9), RiskLevel.sedang),
        _assessment('earliest', DateTime(2026, 10, 10, 10), RiskLevel.tinggi),
        _assessment('outside', DateTime(2026, 10, 9, 12), RiskLevel.tinggi),
      ];
      final originalIds = input.map((assessment) => assessment.id).toList();

      final statistics = WeeklyRiskStatistics.fromAssessments(
        input,
        now: DateTime(2026, 10, 16, 12),
      );

      expect(statistics.assessments, hasLength(11));
      expect(statistics.days, hasLength(7));
      expect(statistics.days.first.date, DateTime(2026, 10, 10));
      expect(statistics.days.last.date, DateTime(2026, 10, 16));
      expect(
        statistics.days[5].assessments.map((assessment) => assessment.id),
        [for (var index = 0; index < 9; index++) 'same-day-$index'],
      );
      expect(statistics.assessments.first.id, 'earliest');
      expect(statistics.assessments.last.id, 'today');
      expect(statistics.countFor(RiskLevel.rendah), 3);
      expect(statistics.countFor(RiskLevel.sedang), 4);
      expect(statistics.countFor(RiskLevel.tinggi), 4);
      expect(input.map((assessment) => assessment.id), originalIds);
      expect(statistics.days[1].assessments, isEmpty);
    },
  );

  test(
    'uses inclusive first-day and exclusive next-day calendar boundaries',
    () {
      final statistics = WeeklyRiskStatistics.fromAssessments([
        _assessment('before', DateTime(2025, 12, 28, 23, 59, 59, 999, 999)),
        _assessment('start', DateTime(2025, 12, 29)),
        _assessment('end', DateTime(2026, 1, 4, 23, 59, 59, 999, 999)),
        _assessment('tomorrow', DateTime(2026, 1, 5)),
        _assessment('future', DateTime(2026, 1, 9)),
      ], now: DateTime(2026, 1, 4, 8));

      expect(statistics.assessments.map((assessment) => assessment.id), [
        'start',
        'end',
      ]);
      expect(statistics.days.map((day) => day.date), [
        DateTime(2025, 12, 29),
        DateTime(2025, 12, 30),
        DateTime(2025, 12, 31),
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 2),
        DateTime(2026, 1, 3),
        DateTime(2026, 1, 4),
      ]);
    },
  );

  test('groups UTC timestamps by their local date and accepts UTC now', () {
    final localYesterday = DateTime(2026, 10, 15, 23, 45);
    final localToday = DateTime(2026, 10, 16, 0, 15);
    final statistics = WeeklyRiskStatistics.fromAssessments([
      _assessment('today', localToday.toUtc()),
      _assessment('yesterday', localYesterday.toUtc()),
    ], now: DateTime(2026, 10, 16, 10).toUtc());

    expect(statistics.days[5].date, DateTime(2026, 10, 15));
    expect(statistics.days[5].assessments.single.id, 'yesterday');
    expect(statistics.days[6].date, DateTime(2026, 10, 16));
    expect(statistics.days[6].assessments.single.id, 'today');
  });

  test('sorts equal timestamps by ID for deterministic chart order', () {
    final takenAt = DateTime(2026, 10, 16, 10);
    final statistics = WeeklyRiskStatistics.fromAssessments([
      _assessment('b', takenAt),
      _assessment('a', takenAt.toUtc()),
    ], now: DateTime(2026, 10, 16));

    expect(statistics.assessments.map((assessment) => assessment.id), [
      'a',
      'b',
    ]);
    expect(
      statistics.days.last.assessments.map((assessment) => assessment.id),
      ['a', 'b'],
    );
  });

  test('empty input still provides seven days with no invented results', () {
    final statistics = WeeklyRiskStatistics.fromAssessments(
      [],
      now: DateTime(2026, 3, 2),
    );

    expect(statistics.days, hasLength(7));
    expect(statistics.days.first.date, DateTime(2026, 2, 24));
    expect(statistics.days.last.date, DateTime(2026, 3, 2));
    expect(statistics.days.every((day) => day.assessments.isEmpty), isTrue);
    expect(statistics.assessments, isEmpty);
    for (final level in RiskLevel.values) {
      expect(statistics.countFor(level), 0);
    }
    expect(() => statistics.days.clear(), throwsUnsupportedError);
    expect(() => statistics.assessments.clear(), throwsUnsupportedError);
    expect(
      () => statistics.days.first.assessments.clear(),
      throwsUnsupportedError,
    );
  });
}
