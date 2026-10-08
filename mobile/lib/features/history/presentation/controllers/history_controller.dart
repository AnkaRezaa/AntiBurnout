import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'history_repository.dart';
import 'history_state.dart';

class HistoryController extends AutoDisposeNotifier<HistoryState> {
  bool _disposed = false;

  @override
  HistoryState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    Future.microtask(load);
    return const HistoryState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ref.read(historyRepositoryProvider).fetchHistory();
      if (_disposed) return;
      final sorted = [...result]..sort((a, b) => b.takenAt.compareTo(a.takenAt));
      state = state.copyWith(items: sorted, isLoading: false);
    } catch (_) {
      if (_disposed) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat riwayat. Coba lagi.',
      );
    }
  }

  void setQuery(String query) => state = state.copyWith(query: query);

  void setFilter(HistoryFilter filter) =>
      state = state.copyWith(filter: filter);
}

final historyControllerProvider =
    NotifierProvider.autoDispose<HistoryController, HistoryState>(
  HistoryController.new,
);