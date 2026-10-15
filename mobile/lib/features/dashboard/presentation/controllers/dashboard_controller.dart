import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../assessment/di/assessment_providers.dart';
import '../../../assessment/domain/entities/assessment.dart';
import '../../../history/presentation/controllers/history_repository.dart';

final latestAssessmentProvider = Provider<Assessment?>((ref) {
  final items = {
    for (final item in ref.watch(assessmentFixtureProvider))
      item.id: Assessment(
        id: item.id,
        riskLevel: item.riskLevel,
        takenAt: item.takenAt,
      ),
    ...ref.watch(assessmentSessionCacheProvider),
  }.values;
  if (items.isEmpty) return null;
  return items.reduce((a, b) => b.takenAt.isAfter(a.takenAt) ? b : a);
});
