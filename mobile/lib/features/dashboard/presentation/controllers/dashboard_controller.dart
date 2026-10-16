import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../assessment/di/assessment_providers.dart';
import '../../../assessment/domain/entities/assessment.dart';
import '../../../history/presentation/controllers/history_repository.dart';

final dashboardAssessmentsProvider = Provider<List<Assessment>>((ref) {
  final items = {
    for (final item in ref.watch(assessmentFixtureProvider))
      item.id: Assessment(
        id: item.id,
        riskLevel: item.riskLevel,
        takenAt: item.takenAt,
        isExample: true,
      ),
    ...ref.watch(assessmentSessionCacheProvider),
  }.values.toList()..sort((a, b) => b.takenAt.compareTo(a.takenAt));
  return List.unmodifiable(items);
});

final latestAssessmentProvider = Provider<Assessment?>((ref) {
  final items = ref.watch(dashboardAssessmentsProvider);
  return items.isEmpty ? null : items.first;
});
