import '../entities/survey_question.dart';

abstract class SurveyRepository {
  Future<List<SurveyQuestion>> getQuestions();
}
