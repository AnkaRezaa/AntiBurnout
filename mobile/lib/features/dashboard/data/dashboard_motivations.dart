import 'dart:math' as math;

/// General encouragement for the dashboard, independent of assessment results.
const dashboardMotivations = [
  'Tidur yang cukup membantu menjaga kesehatan mental dan produktivitasmu.',
  'Langkah kecil hari ini tetap berarti. Kamu boleh bergerak sesuai kemampuanmu.',
  'Beristirahat sejenak memberi ruang untuk memulai kembali.',
  'Tidak semuanya perlu selesai sekaligus. Mulailah dari satu hal yang paling penting.',
  'Beri apresiasi pada dirimu atas usaha yang sudah kamu lakukan hari ini.',
  'Di sela kesibukan, sisihkan sedikit waktu untuk hal yang kamu nikmati.',
  'Saat merasa kewalahan, kamu boleh meminta bantuan orang yang kamu percaya.',
  'Berikan dirimu izin untuk berhenti sejenak dan mengatur ulang prioritas.',
  'Hari yang berat tidak menghapus kemajuan yang sudah kamu buat.',
  'Kamu boleh menetapkan batas ketika tenaga dan waktumu sedang terbatas.',
  'Luangkan waktu untuk terhubung dengan orang yang membuatmu merasa didengar.',
  'Mulai lagi dengan satu langkah kecil. Tidak semuanya harus sempurna.',
];

final _dailyMotivations = List<String>.unmodifiable(
  [...dashboardMotivations]..shuffle(math.Random(42)),
);

/// A stable daily choice shared by every visit and app restart on that date.
/// Use calendar components in UTC only for the day index, so daylight-saving
/// changes do not skip or repeat an index. The date itself follows the device.
String motivationForDate(DateTime date) {
  final local = date.toLocal();
  final dayIndex =
      DateTime.utc(local.year, local.month, local.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
  return _dailyMotivations[dayIndex % _dailyMotivations.length];
}
