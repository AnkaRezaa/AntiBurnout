import '../../../assessment/domain/entities/assessment.dart';

class WeeklyRiskStatistics {
  WeeklyRiskStatistics._({required this.days, required this.assessments});

  /// Includes today and the six preceding calendar days in local time.
  /// Every assessment in the period is retained, including multiple results
  /// recorded on the same day.
  factory WeeklyRiskStatistics.fromAssessments(
    Iterable<Assessment> assessments, {
    required DateTime now,
  }) {
    final localNow = now.toLocal();
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final firstDay = DateTime(today.year, today.month, today.day - 6);
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final weeklyAssessments =
        assessments.where((assessment) {
          final takenAt = assessment.takenAt.toLocal();
          return !takenAt.isBefore(firstDay) && takenAt.isBefore(tomorrow);
        }).toList()..sort((a, b) {
          final byTime = a.takenAt.compareTo(b.takenAt);
          return byTime == 0 ? a.id.compareTo(b.id) : byTime;
        });

    final byDate = <DateTime, List<Assessment>>{};
    for (final assessment in weeklyAssessments) {
      final takenAt = assessment.takenAt.toLocal();
      final date = DateTime(takenAt.year, takenAt.month, takenAt.day);
      (byDate[date] ??= []).add(assessment);
    }

    final days = [
      for (var offset = 6; offset >= 0; offset--)
        DateTime(today.year, today.month, today.day - offset),
    ];
    return WeeklyRiskStatistics._(
      days: List.unmodifiable([
        for (final date in days)
          DailyRiskAssessments._(
            date: date,
            assessments: List.unmodifiable(byDate[date] ?? []),
          ),
      ]),
      assessments: List.unmodifiable(weeklyAssessments),
    );
  }

  final List<DailyRiskAssessments> days;
  final List<Assessment> assessments;

  int countFor(RiskLevel level) =>
      assessments.where((assessment) => assessment.riskLevel == level).length;
}

class DailyRiskAssessments {
  const DailyRiskAssessments._({required this.date, required this.assessments});

  final DateTime date;
  final List<Assessment> assessments;
}
