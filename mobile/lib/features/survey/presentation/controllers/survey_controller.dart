import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../assessment/di/assessment_providers.dart';
import '../../../assessment/domain/entities/assessment.dart';
import '../../di/survey_providers.dart';
import 'survey_state.dart';

class SurveyController extends AutoDisposeFamilyNotifier<SurveyState, String> {
  bool _disposed = false;

  @override
  SurveyState build(String sessionKey) {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    Future.microtask(load);
    return const SurveyState(isLoading: true);
  }

  Future<void> load() async {
    if (_disposed || state.isSubmitting || state.completedAssessment != null) {
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final questions = await ref.read(surveyRepositoryProvider).getQuestions();
      if (_disposed) return;
      state = state.copyWith(
        questions: List.unmodifiable(questions),
        isLoading: false,
      );
    } catch (_) {
      if (_disposed) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Pertanyaan survei gagal dimuat. Coba lagi.',
      );
    }
  }

  void setAnswer(String questionId, String answer) {
    if (_disposed || state.isSubmitting || state.completedAssessment != null) {
      return;
    }
    final question = state.questions.where((item) => item.id == questionId);
    if (question.isEmpty) return;
    if (question.first.options.isNotEmpty &&
        !question.first.options.contains(answer)) {
      return;
    }
    state = state.copyWith(
      answers: Map.unmodifiable({...state.answers, questionId: answer}),
      clearError: true,
    );
  }

  Future<Assessment?> submit() async {
    if (_disposed || !state.canSubmit) return null;
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final assessment = await ref.read(submitAssessmentProvider)(
        state.answers,
      );
      if (_disposed) return null;
      final cache = ref.read(assessmentSessionCacheProvider.notifier);
      cache.state = {...cache.state, assessment.id: assessment};
      ref.invalidate(assessmentByIdProvider(assessment.id));
      state = state.copyWith(
        isSubmitting: false,
        completedAssessment: assessment,
      );
      return assessment;
    } on UnsupportedError {
      if (_disposed) return null;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Layanan asesmen belum tersedia. Jawaban belum dikirim.',
      );
    } catch (_) {
      if (_disposed) return null;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Jawaban gagal dikirim. Coba lagi.',
      );
    }
    return null;
  }
}

final surveyControllerProvider = NotifierProvider.autoDispose
    .family<SurveyController, SurveyState, String>(SurveyController.new);
