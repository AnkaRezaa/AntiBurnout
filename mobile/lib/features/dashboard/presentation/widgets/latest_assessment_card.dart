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
    this.onViewResult,
  });

  final RiskLevel? riskLevel;
  final String date;
  final VoidCallback? onViewResult;

  Color _riskColor(BuildContext context) => switch (riskLevel) {
    RiskLevel.rendah => AssessmentColors.riskLow,
    RiskLevel.sedang => AssessmentColors.riskMedium,
    RiskLevel.tinggi => AssessmentColors.riskHigh,
    null => AppColors.of(context).hint,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.ui(22)),
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: BorderRadius.circular(context.ui(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.of(context).shadow,
            blurRadius: context.ui(22),
            offset: Offset(0, context.ui(AppSpacing.sm)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'HASIL ASESMEN TERAKHIR',
            style: AppTextStyles.subtitle(context).copyWith(
              fontSize: context.ui(12),
              fontWeight: FontWeight.w700,
              color: AppColors.of(context).hint,
            ),
          ),
          SizedBox(height: context.ui(AppSpacing.sm)),
          _buildRiskHeading(context),
          SizedBox(height: context.ui(AppSpacing.lg)),
          if (riskLevel == null)
            Text(
              'Mulai survei untuk mengenali kondisi keseharianmu.',
              style: AppTextStyles.subtitle(context)
                  .copyWith(fontSize: context.ui(14)),
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
                    style: AppTextStyles.subtitle(context).copyWith(
                      fontSize: context.ui(11),
                      color: isSelected
                          ? AppColors.of(context).navy
                          : AppColors.of(context).hint,
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
          Divider(height: 1, color: AppColors.of(context).border),
          SizedBox(height: context.ui(AppSpacing.sm)),
          Wrap(
            spacing: context.ui(AppSpacing.sm),
            runSpacing: context.ui(AppSpacing.xs),
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                date,
                style: AppTextStyles.subtitle(context).copyWith(
                  fontSize: context.ui(12),
                  color: AppColors.of(context).hint,
                ),
              ),
              if (onViewResult != null)
                TextButton(
                  onPressed: onViewResult,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: EdgeInsets.symmetric(horizontal: context.ui(4)),
                  ),
                  child: Text(
                    'Lihat Detail ›',
                    style: AppTextStyles.link(context)
                        .copyWith(fontSize: context.ui(12)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskHeading(BuildContext context) {
    final title = Text(
      'Risiko Burnout',
      style: AppTextStyles.title(context).copyWith(fontSize: context.ui(22)),
    );
    if (riskLevel == null) return title;

    final badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.ui(12),
        vertical: context.ui(6),
      ),
      decoration: BoxDecoration(
        color: _riskColor(context).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.ui(20)),
      ),
      child: Text(
        riskLevel!.label.toUpperCase(),
        style: AppTextStyles.link(context)
            .copyWith(fontSize: context.ui(11), color: _riskColor(context)),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScaler = MediaQuery.textScalerOf(context);
        if (constraints.maxWidth < context.ui(270) ||
            textScaler.scale(14) > 20) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              SizedBox(height: context.ui(AppSpacing.sm)),
              Align(alignment: Alignment.centerRight, child: badge),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: title),
            SizedBox(width: context.ui(AppSpacing.sm)),
            badge,
          ],
        );
      },
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
            Container(
              height: context.ui(5),
              color: AppColors.of(context).border,
            ),
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
                        ? AppColors.of(context).blob
                        : AppColors.of(context).border,
                  ),
                  child: level == riskLevel
                      ? Center(
                          child: Container(
                            width: context.ui(10),
                            height: context.ui(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.of(context).primary,
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
