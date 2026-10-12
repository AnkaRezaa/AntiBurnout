enum RiskLevel {
  rendah('Rendah'),
  sedang('Sedang'),
  tinggi('Tinggi');

  const RiskLevel(this.label);
  final String label;
}

class AssessmentHistoryItem {
  final String id;
  final RiskLevel riskLevel;
  final DateTime takenAt;

  const AssessmentHistoryItem({
    required this.id,
    required this.riskLevel,
    required this.takenAt,
  });

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  /// Contoh: "18 September 2026 • 20:15"
  String get dateTimeLabel {
    final hh = takenAt.hour.toString().padLeft(2, '0');
    final mm = takenAt.minute.toString().padLeft(2, '0');
    return '${takenAt.day} ${_months[takenAt.month - 1]} ${takenAt.year} • $hh:$mm';
  }
}