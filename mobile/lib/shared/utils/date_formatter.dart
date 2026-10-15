String formatAssessmentDate(DateTime date, {bool includeTime = false}) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final local = date.toLocal();
  final label = '${local.day} ${months[local.month - 1]} ${local.year}';
  if (!includeTime) return label;
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '$label • $hh:$mm';
}
