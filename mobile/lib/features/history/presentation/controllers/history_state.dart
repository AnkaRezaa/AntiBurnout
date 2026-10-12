import '../widgets/assessment_history_item.dart';

enum HistoryFilter {
  semua('Semua', null),
  rendah('Rendah', RiskLevel.rendah),
  sedang('Sedang', RiskLevel.sedang),
  tinggi('Tinggi', RiskLevel.tinggi);

  const HistoryFilter(this.label, this.risk);
  final String label;
  final RiskLevel? risk;
}

class HistoryState {
  /// Semua riwayat, terurut dari yang terbaru.
  final List<AssessmentHistoryItem> items;
  final String query;
  final HistoryFilter filter;
  final bool isLoading;
  final String? errorMessage;

  const HistoryState({
    this.items = const [],
    this.query = '',
    this.filter = HistoryFilter.semua,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Id asesmen terbaru (untuk keterangan "Hasil asesmen terbaru").
  String? get latestId => items.isEmpty ? null : items.first.id;

  List<AssessmentHistoryItem> get visibleItems {
    final q = query.trim().toLowerCase();
    return items.where((item) {
      final matchFilter = filter.risk == null || item.riskLevel == filter.risk;
      final matchQuery = q.isEmpty ||
          item.riskLevel.label.toLowerCase().contains(q) ||
          item.dateTimeLabel.toLowerCase().contains(q);
      return matchFilter && matchQuery;
    }).toList();
  }

  HistoryState copyWith({
    List<AssessmentHistoryItem>? items,
    String? query,
    HistoryFilter? filter,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HistoryState(
      items: items ?? this.items,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}