import '../../domain/entities/survey_question.dart';
import '../../domain/repositories/survey_repository.dart';

/// No questionnaire has been configured yet. Questions must come from a source.
class InMemorySurveyRepository implements SurveyRepository {
  const InMemorySurveyRepository({this.questions = const []});

  final List<SurveyQuestion> questions;

  @override
  Future<List<SurveyQuestion>> getQuestions() async =>
      List.unmodifiable(questions);
}
