import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/in_memory_survey_repository.dart';
import '../domain/repositories/survey_repository.dart';

final surveyRepositoryProvider = Provider<SurveyRepository>(
  (ref) => const InMemorySurveyRepository(),
);
