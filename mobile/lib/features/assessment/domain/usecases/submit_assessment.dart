import '../entities/assessment.dart';
import '../repositories/assessment_repository.dart';

class SubmitAssessment {
  const SubmitAssessment(this._repository);

  final AssessmentRepository _repository;

  Future<Assessment> call(Map<String, String> answers) async {
    final assessment = await _repository.submit(Map.unmodifiable(answers));
    if (assessment.id.trim().isEmpty) {
      throw const FormatException('ID hasil asesmen belum tersedia.');
    }
    return assessment;
  }
}
