import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/assessment_history_item.dart';

abstract class HistoryRepository {
  Future<List<AssessmentHistoryItem>> fetchHistory();
}

/// Data dummy. Ganti dengan implementasi API nanti, lalu ubah provider di bawah.
class DummyHistoryRepository implements HistoryRepository {
  @override
  Future<List<AssessmentHistoryItem>> fetchHistory() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      AssessmentHistoryItem(
        id: '4',
        riskLevel: RiskLevel.sedang,
        takenAt: DateTime(2026, 9, 18, 20, 15),
      ),
      AssessmentHistoryItem(
        id: '3',
        riskLevel: RiskLevel.rendah,
        takenAt: DateTime(2026, 9, 10, 19, 40),
      ),
      AssessmentHistoryItem(
        id: '2',
        riskLevel: RiskLevel.sedang,
        takenAt: DateTime(2026, 9, 2, 21, 10),
      ),
      AssessmentHistoryItem(
        id: '1',
        riskLevel: RiskLevel.tinggi,
        takenAt: DateTime(2026, 8, 24, 18, 25),
      ),
    ];
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => DummyHistoryRepository(),
);