import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../assessment/di/assessment_providers.dart';
import '../widgets/assessment_history_item.dart';
import 'history_repository.dart';
import 'history_state.dart';

class HistoryController extends AutoDisposeNotifier<HistoryState> {
  bool _disposed = false;
  List<AssessmentHistoryItem> _fetchedItems = [];

  @override
  HistoryState build() {
    _disposed = false;
    _fetchedItems = [];
    ref.onDispose(() => _disposed = true);
    ref.listen(assessmentSessionCacheProvider, (previous, next) {
      if (!_disposed) {
        state = state.copyWith(items: _withSubmitted(_fetchedItems));
      }
    });
    Future.microtask(load);
    return const HistoryState(isLoading: true);
  }

  Future<void> load() async {
    if (_disposed) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ref.read(historyRepositoryProvider).fetchHistory();
      if (_disposed) return;
      _fetchedItems = result;
      final sorted = _withSubmitted(result);
      state = state.copyWith(items: sorted, isLoading: false);
    } catch (_) {
      if (_disposed) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat riwayat. Coba lagi.',
      );
    }
  }

  List<AssessmentHistoryItem> _withSubmitted(
    List<AssessmentHistoryItem> items,
  ) {
    final byId = {for (final item in items) item.id: item};
    for (final assessment in ref.read(assessmentSessionCacheProvider).values) {
      byId[assessment.id] = AssessmentHistoryItem(
        id: assessment.id,
        riskLevel: assessment.riskLevel,
        takenAt: assessment.takenAt,
      );
    }
    return byId.values.toList()..sort((a, b) => b.takenAt.compareTo(a.takenAt));
  }

  void setQuery(String query) => state = state.copyWith(query: query);

  void setFilter(HistoryFilter filter) =>
      state = state.copyWith(filter: filter);
}

final historyControllerProvider =
    NotifierProvider.autoDispose<HistoryController, HistoryState>(
      HistoryController.new,
    );
