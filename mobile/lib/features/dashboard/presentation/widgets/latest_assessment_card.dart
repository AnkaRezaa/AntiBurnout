import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/assessment_colors.dart';
import '../../../history/presentation/widgets/assessment_history_item.dart';

class LatestAssessmentCard extends StatelessWidget {
  const LatestAssessmentCard({
    super.key,
    required this.riskLevel,
    required this.date,
    this.onHistoryTap,
  });

  final RiskLevel? riskLevel;
  final String date;
  final VoidCallback? onHistoryTap;

  Color get _riskColor => switch (riskLevel) {
    RiskLevel.rendah => AssessmentColors.riskLow,
    RiskLevel.sedang => AssessmentColors.riskMedium,
    RiskLevel.tinggi => AssessmentColors.riskHigh,
    null => AppColors.hint,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.ui(22)),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(context.ui(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.07),
            blurRadius: context.ui(22),
            offset: Offset(0, context.ui(AppSpacing.sm)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HASIL ASESMEN TERAKHIR',
            style: AppTextStyles.subtitle.copyWith(
              fontSize: context.ui(12),
              fontWeight: FontWeight.w700,
              color: AppColors.hint,
            ),
          ),
          SizedBox(height: context.ui(AppSpacing.sm)),
          Wrap(
            spacing: context.ui(AppSpacing.md),
            runSpacing: context.ui(AppSpacing.sm),
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Risiko Burnout',
                style: AppTextStyles.title.copyWith(fontSize: context.ui(22)),
              ),
              if (riskLevel != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.ui(12),
                    vertical: context.ui(6),
                  ),
                  decoration: BoxDecoration(
                    color: _riskColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(context.ui(20)),
                  ),
                  child: Text(
                    riskLevel!.label.toUpperCase(),
                    style: AppTextStyles.link.copyWith(
                      fontSize: context.ui(11),
                      color: _riskColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.ui(AppSpacing.lg)),
          if (riskLevel == null)
            Text(
              'Mulai survei untuk mengenali kondisi keseharianmu.',
              style: AppTextStyles.subtitle.copyWith(fontSize: context.ui(14)),
            )
          else ...[
            _buildRiskBar(context),
            SizedBox(height: context.ui(AppSpacing.sm)),
            Row(
              children: RiskLevel.values.map((level) {
                final isSelected = level == riskLevel;
                return Expanded(
                  child: Text(
                    level.label,
                    textAlign: switch (level) {
                      RiskLevel.rendah => TextAlign.start,
                      RiskLevel.sedang => TextAlign.center,
                      RiskLevel.tinggi => TextAlign.end,
                    },
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: context.ui(11),
                      color: isSelected ? AppColors.navy : AppColors.hint,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          SizedBox(height: context.ui(AppSpacing.md)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: context.ui(AppSpacing.sm)),
          Wrap(
            spacing: context.ui(AppSpacing.sm),
            runSpacing: context.ui(AppSpacing.xs),
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                date,
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: context.ui(12),
                  color: AppColors.hint,
                ),
              ),
              if (onHistoryTap != null)
                TextButton(
                  onPressed: onHistoryTap,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: EdgeInsets.symmetric(horizontal: context.ui(4)),
                  ),
                  child: Text(
                    'Lihat Riwayat ›',
                    style: AppTextStyles.link.copyWith(
                      fontSize: context.ui(12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.ui(AppSpacing.sm)),
      child: SizedBox(
        height: context.ui(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(height: context.ui(5), color: AppColors.border),
            for (final level in RiskLevel.values)
              Align(
                alignment: switch (level) {
                  RiskLevel.rendah => Alignment.centerLeft,
                  RiskLevel.sedang => Alignment.center,
                  RiskLevel.tinggi => Alignment.centerRight,
                },
                child: Container(
                  width: context.ui(18),
                  height: context.ui(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: level == riskLevel
                        ? AppColors.blob
                        : AppColors.border,
                  ),
                  child: level == riskLevel
                      ? Center(
                          child: Container(
                            width: context.ui(10),
                            height: context.ui(10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
