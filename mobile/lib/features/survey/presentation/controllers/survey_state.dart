import '../../../assessment/domain/entities/assessment.dart';
import '../../domain/entities/survey_question.dart';

class SurveyState {
  const SurveyState({
    this.questions = const [],
    this.answers = const {},
    this.isLoading = false,
    this.isSubmitting = false,
    this.completedAssessment,
    this.errorMessage,
  });

  final List<SurveyQuestion> questions;
  final Map<String, String> answers;
  final bool isLoading;
  final bool isSubmitting;
  final Assessment? completedAssessment;
  final String? errorMessage;

  bool get canSubmit =>
      !isLoading &&
      !isSubmitting &&
      completedAssessment == null &&
      questions.isNotEmpty &&
      questions.every(
        (question) => answers[question.id]?.trim().isNotEmpty == true,
      );

  SurveyState copyWith({
    List<SurveyQuestion>? questions,
    Map<String, String>? answers,
    bool? isLoading,
    bool? isSubmitting,
    Assessment? completedAssessment,
    String? errorMessage,
    bool clearError = false,
  }) => SurveyState(
    questions: questions ?? this.questions,
    answers: answers ?? this.answers,
    isLoading: isLoading ?? this.isLoading,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    completedAssessment: completedAssessment ?? this.completedAssessment,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}
