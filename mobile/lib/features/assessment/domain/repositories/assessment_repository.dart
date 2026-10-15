import '../entities/assessment.dart';

abstract class AssessmentRepository {
  Future<Assessment?> getById(String id);

  Future<Assessment> submit(Map<String, String> answers);
}
