import '../../domain/entities/survey_question.dart';
import '../fixtures/survey_questions.dart';
import '../../domain/repositories/survey_repository.dart';

/// Local questionnaire UI; assessment submission still requires a real service.
class InMemorySurveyRepository implements SurveyRepository {
  const InMemorySurveyRepository({this.questions = surveyQuestions});

  final List<SurveyQuestion> questions;

  @override
  Future<List<SurveyQuestion>> getQuestions() async =>
      List.unmodifiable(questions);
}
