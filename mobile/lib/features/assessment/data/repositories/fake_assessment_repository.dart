import '../../domain/entities/assessment.dart';
import '../../domain/repositories/assessment_repository.dart';

/// Read-only access to the existing sample history until a service is supplied.
/// This repository does not generate predictions or explanations.
class FakeAssessmentRepository implements AssessmentRepository {
  FakeAssessmentRepository(Iterable<Assessment> assessments)
    : _assessments = {for (final item in assessments) item.id: item};

  final Map<String, Assessment> _assessments;

  @override
  Future<Assessment?> getById(String id) async => _assessments[id];

  @override
  Future<Assessment> submit(Map<String, String> answers) async {
    throw UnsupportedError('Layanan asesmen belum tersedia.');
  }
}
