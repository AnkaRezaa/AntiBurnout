import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/assessment_history_item.dart';

abstract class HistoryRepository {
  Future<List<AssessmentHistoryItem>> fetchHistory();
}

final assessmentFixtureProvider = Provider<List<AssessmentHistoryItem>>((ref) {
  return createDemoAssessmentHistory(now: DateTime.now());
});

/// Seeded UI examples cover ten local calendar days, including several surveys
/// per day. The provider creates them once so normal rebuilds keep them stable.
List<AssessmentHistoryItem> createDemoAssessmentHistory({
  required DateTime now,
}) {
  final localNow = now.toLocal();
  final today = DateTime(localNow.year, localNow.month, localNow.day);
  final random = math.Random(42);
  final items = [
    AssessmentHistoryItem(id: '4', riskLevel: RiskLevel.sedang, takenAt: today),
    AssessmentHistoryItem(
      id: '3',
      riskLevel: RiskLevel.rendah,
      takenAt: DateTime(today.year, today.month, today.day - 1, 9, 40),
    ),
    AssessmentHistoryItem(
      id: '2',
      riskLevel: RiskLevel.sedang,
      takenAt: DateTime(today.year, today.month, today.day - 3, 21, 10),
    ),
    AssessmentHistoryItem(
      id: '1',
      riskLevel: RiskLevel.tinggi,
      takenAt: DateTime(today.year, today.month, today.day - 6, 18, 25),
    ),
  ];
  for (var offset = 1; offset <= 9; offset++) {
    final count = 1 + random.nextInt(3);
    for (var index = 0; index < count; index++) {
      items.add(
        AssessmentHistoryItem(
          id: 'demo-$offset-$index',
          riskLevel: RiskLevel.values[random.nextInt(RiskLevel.values.length)],
          takenAt: DateTime(
            today.year,
            today.month,
            today.day - offset,
            random.nextInt(24),
            random.nextInt(60),
          ),
        ),
      );
    }
  }
  items.sort((a, b) {
    final byTime = b.takenAt.compareTo(a.takenAt);
    return byTime == 0 ? a.id.compareTo(b.id) : byTime;
  });
  return List.unmodifiable(items);
}

class DummyHistoryRepository implements HistoryRepository {
  DummyHistoryRepository(this._items);

  final List<AssessmentHistoryItem> _items;

  @override
  Future<List<AssessmentHistoryItem>> fetchHistory() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_items);
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => DummyHistoryRepository(ref.watch(assessmentFixtureProvider)),
);
