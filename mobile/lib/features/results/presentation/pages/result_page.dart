import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/assessment_colors.dart';
import '../../../../shared/utils/date_formatter.dart';
import '../../../assessment/di/assessment_providers.dart';
import '../../../assessment/domain/entities/risk_level.dart';
import '../widgets/risk_summary_card.dart';

class ResultPage extends ConsumerWidget {
  const ResultPage({
    super.key,
    required this.assessmentId,
    this.onBack,
    this.onRecommendationTap,
  });

  final String assessmentId;
  final VoidCallback? onBack;
  final VoidCallback? onRecommendationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessment = ref.watch(assessmentByIdProvider(assessmentId));
    final goBack = onBack ?? () => Navigator.of(context).maybePop();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: assessment.when(
          loading: () => _ResultStatus(
            onBack: goBack,
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => _ResultStatus(
            onBack: goBack,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hasil asesmen belum dapat dimuat.',
                  style: AppTextStyles.subtitle,
                ),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(assessmentByIdProvider(assessmentId)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
          data: (item) {
            if (item == null) {
              return _ResultStatus(
                onBack: goBack,
                child: const Text(
                  'Hasil asesmen tidak ditemukan. Buka hasil dari riwayat '
                  'atau selesaikan survei terlebih dahulu.',
                  style: AppTextStyles.subtitle,
                ),
              );
            }

            final (label, color) = switch (item.riskLevel) {
              RiskLevel.rendah => ('Rendah', AssessmentColors.riskLow),
              RiskLevel.sedang => ('Sedang', AssessmentColors.riskMedium),
              RiskLevel.tinggi => ('Tinggi', AssessmentColors.riskHigh),
            };
            return RiskSummaryCard(
              key: ValueKey(item.id),
              scrollKey: PageStorageKey('result-scroll-${item.id}'),
              title: 'Hasil Prediksi',
              level: label,
              levelColor: color,
              ringColor: color,
              description:
                  'Hasil asesmen menunjukkan indikasi risiko burnout '
                  'pada tingkat ${label.toLowerCase()}.',
              assessmentDate: formatAssessmentDate(item.takenAt),
              disclaimer:
                  'Ini bukan diagnosis medis, tetapi indikasi awal '
                  'yang dapat membantumu lebih memahami kondisi diri.',
              factors: [
                for (final factor in item.modelFactors)
                  FactorItemData(
                    icon: Icons.insights_outlined,
                    label: factor.label,
                    backgroundColor: AssessmentColors.activityTint,
                    iconColor: AppColors.primary,
                  ),
              ],
              answerSummary: [
                for (final answer in item.answerSummary)
                  AnswerSummaryItemData(
                    label: answer.label,
                    value: answer.value,
                  ),
              ],
              onBackTap: goBack,
              onRecommendationTap: onRecommendationTap,
            );
          },
        ),
      ),
    );
  }
}

class _ResultStatus extends StatelessWidget {
  const _ResultStatus({required this.onBack, required this.child});

  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.ui(AppSpacing.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResultHeader(title: 'Hasil Prediksi', onBack: onBack),
          SizedBox(height: context.ui(AppSpacing.xl)),
          child,
        ],
      ),
    );
  }
}
