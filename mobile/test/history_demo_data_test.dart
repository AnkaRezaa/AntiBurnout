import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/history/presentation/controllers/history_repository.dart';
import 'package:mobile/features/history/presentation/widgets/assessment_history_item.dart';

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

void main() {
  for (final now in [
    DateTime(2026, 10, 16, 12),
    DateTime(2026, 1, 1),
    DateTime(2024, 3, 1),
  ]) {
    test(
      'demo history covers ten calendar days without future data at $now',
      () {
        final items = createDemoAssessmentHistory(now: now);
        final today = _dateOnly(now);
        final firstDay = DateTime(today.year, today.month, today.day - 9);
        final firstChartDay = DateTime(today.year, today.month, today.day - 6);
        final dates = items.map((item) => _dateOnly(item.takenAt)).toSet();

        expect(items.length, greaterThan(4));
        expect(items.map((item) => item.id).toSet(), hasLength(items.length));
        expect(dates, hasLength(10));
        expect(
          dates,
          unorderedEquals([
            for (var offset = 0; offset < 10; offset++)
              DateTime(today.year, today.month, today.day - offset),
          ]),
        );
        for (final item in items) {
          expect(item.takenAt.isBefore(firstDay), isFalse);
          expect(item.takenAt.isAfter(now), isFalse);
        }
        for (var index = 1; index < items.length; index++) {
          expect(
            items[index - 1].takenAt.isBefore(items[index].takenAt),
            isFalse,
          );
        }
        expect(
          dates.where((date) => date.isBefore(firstChartDay)),
          hasLength(3),
        );
        final counts = <DateTime, int>{};
        for (final item in items) {
          final date = _dateOnly(item.takenAt);
          counts[date] = (counts[date] ?? 0) + 1;
        }
        expect(counts.values.any((count) => count > 1), isTrue);
        expect(
          items.map((item) => item.riskLevel).toSet(),
          unorderedEquals(RiskLevel.values),
        );
      },
    );
  }

  test(
    'original routes and latest risk remain stable in the expanded preview',
    () {
      final now = DateTime(2026, 10, 16);
      final items = createDemoAssessmentHistory(now: now);
      final byId = {for (final item in items) item.id: item};
      expect(items.first.id, '4');
      expect(items.first.riskLevel, RiskLevel.sedang);
      expect(items.first.takenAt, now);
      expect(byId['3']!.riskLevel, RiskLevel.rendah);
      expect(byId['3']!.takenAt, DateTime(2026, 10, 15, 9, 40));
      expect(byId['2']!.riskLevel, RiskLevel.sedang);
      expect(byId['2']!.takenAt, DateTime(2026, 10, 13, 21, 10));
      expect(byId['1']!.riskLevel, RiskLevel.tinggi);
      expect(byId['1']!.takenAt, DateTime(2026, 10, 10, 18, 25));
      expect(
        byId.keys.where((id) => !['1', '2', '3', '4'].contains(id)),
        everyElement(matches(RegExp(r'^demo-[1-9]-[0-2]$'))),
      );
    },
  );

  test('seeded demo records stay identical throughout the same day', () {
    final early = createDemoAssessmentHistory(now: DateTime(2026, 10, 16));
    final later = createDemoAssessmentHistory(
      now: DateTime(2026, 10, 16, 23, 59),
    );
    expect(
      later.map((item) => (item.id, item.riskLevel, item.takenAt)),
      early.map((item) => (item.id, item.riskLevel, item.takenAt)),
    );
    expect(() => early.clear(), throwsUnsupportedError);
  });

  test('demo fixture provider caches its generated records', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final firstRead = container.read(assessmentFixtureProvider);
    expect(container.read(assessmentFixtureProvider), same(firstRead));
    expect(firstRead, hasLength(greaterThan(4)));
  });
}
