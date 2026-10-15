import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../assessment/domain/entities/assessment.dart';
import '../../domain/entities/survey_question.dart';
import '../controllers/survey_controller.dart';
import '../controllers/survey_state.dart';
import '../widgets/survey_stepper.dart';

class SurveyQuestionPage extends ConsumerWidget {
  const SurveyQuestionPage({
    super.key,
    required this.sessionKey,
    required this.onBack,
    required this.onSubmitted,
  });

  final String sessionKey;
  final VoidCallback onBack;
  final ValueChanged<Assessment> onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(surveyControllerProvider(sessionKey));
    if (!state.isLoading &&
        state.questions.any(
          (question) => question.inputKind != SurveyInputKind.text,
        )) {
      final controller = ref.read(
        surveyControllerProvider(sessionKey).notifier,
      );
      return SurveyStepper(
        state: state,
        onBack: onBack,
        onChanged: controller.setAnswer,
        onSubmit: () async {
          final assessment = await controller.submit();
          if (!context.mounted || assessment == null) return;
          onSubmitted(assessment);
        },
      );
    }
    return PopScope(
      canPop: !state.isSubmitting,
      child: Scaffold(
        backgroundColor: AppColors.of(context).background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: CustomScrollView(
                key: const PageStorageKey('survey-questions-scroll'),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      context.ui(AppSpacing.page),
                      context.ui(AppSpacing.md),
                      context.ui(AppSpacing.page),
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          AppBackButton(
                            tooltip: 'Kembali ke pengantar survei',
                            onPressed: state.isSubmitting ? null : onBack,
                          ),
                          SizedBox(width: context.ui(AppSpacing.sm)),
                          Expanded(
                            child: Text(
                              'Survei Harian',
                              style: AppTextStyles.title(context)
                                  .copyWith(fontSize: context.ui(22)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(context.ui(AppSpacing.page)),
                    sliver: SliverToBoxAdapter(
                      child: _buildContent(context, ref, state),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, SurveyState state) {
    final controller = ref.read(surveyControllerProvider(sessionKey).notifier);
    if (state.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: context.ui(AppSpacing.xxl)),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.questions.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: context.ui(56),
            color: AppColors.of(context).primary,
          ),
          SizedBox(height: context.ui(AppSpacing.md)),
          Text(
            state.errorMessage == null
                ? 'Survei belum tersedia'
                : 'Survei gagal dimuat',
            textAlign: TextAlign.center,
            style: AppTextStyles.title(context)
                .copyWith(fontSize: context.ui(20)),
          ),
          SizedBox(height: context.ui(AppSpacing.sm)),
          Text(
            state.errorMessage ??
                'Pertanyaan dan layanan asesmen belum tersedia. '
                    'Silakan kembali lagi nanti.',
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle(context)
                .copyWith(fontSize: context.ui(14)),
          ),
          SizedBox(height: context.ui(AppSpacing.lg)),
          if (state.errorMessage != null) ...[
            AppButton(label: 'Coba Lagi', onPressed: controller.load),
            SizedBox(height: context.ui(AppSpacing.sm)),
          ],
          AppButton(label: 'Kembali ke Pengantar', onPressed: onBack),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Jawab sesuai kondisi yang kamu rasakan.',
          style: AppTextStyles.subtitle(context)
              .copyWith(fontSize: context.ui(14)),
        ),
        SizedBox(height: context.ui(AppSpacing.lg)),
        for (final question in state.questions) ...[
          _QuestionInput(
            question: question,
            value: state.answers[question.id],
            enabled: !state.isSubmitting && state.completedAssessment == null,
            onChanged: (answer) => controller.setAnswer(question.id, answer),
          ),
          SizedBox(height: context.ui(AppSpacing.lg)),
        ],
        if (state.errorMessage != null) ...[
          Semantics(
            liveRegion: true,
            child: Text(
              state.errorMessage!,
              style: AppTextStyles.subtitle(context).copyWith(
                color: AppColors.of(context).error,
                fontSize: context.ui(14),
              ),
            ),
          ),
          SizedBox(height: context.ui(AppSpacing.md)),
        ],
        AppButton(
          label: 'Kirim Jawaban',
          isLoading: state.isSubmitting,
          onPressed: state.canSubmit
              ? () async {
                  final assessment = await controller.submit();
                  if (!context.mounted || assessment == null) return;
                  onSubmitted(assessment);
                }
              : null,
        ),
      ],
    );
  }
}

class _QuestionInput extends StatelessWidget {
  const _QuestionInput({
    required this.question,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final SurveyQuestion question;
  final String? value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          question.label,
          style: AppTextStyles.subtitle(context).copyWith(
            color: AppColors.of(context).navy,
            fontWeight: FontWeight.w700,
            fontSize: context.ui(16),
          ),
        ),
        SizedBox(height: context.ui(AppSpacing.sm)),
        if (question.options.isEmpty)
          TextFormField(
            key: ValueKey('survey-answer-${question.id}'),
            initialValue: value,
            enabled: enabled,
            onChanged: onChanged,
            minLines: 1,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Tulis jawabanmu',
              border: OutlineInputBorder(),
            ),
          )
        else
          Wrap(
            spacing: context.ui(AppSpacing.sm),
            runSpacing: context.ui(AppSpacing.sm),
            children: [
              for (final option in question.options)
                ChoiceChip(
                  label: Text(option),
                  selected: value == option,
                  onSelected: enabled ? (_) => onChanged(option) : null,
                ),
            ],
          ),
      ],
    );
  }
}
