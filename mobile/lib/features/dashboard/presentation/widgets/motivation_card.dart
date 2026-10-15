import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/assessment_colors.dart';

class MotivationCard extends StatelessWidget {
  const MotivationCard({
    super.key,
    this.quote = 'Tidur yang cukup membantu menjaga kesehatan mental dan produktivitasmu.',
  });

  final String quote;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motivasi Hari Ini',
          style: AppTextStyles.title(context)
              .copyWith(fontSize: context.ui(17), fontWeight: FontWeight.w700),
        ),
        SizedBox(height: context.ui(AppSpacing.md)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.ui(18)),
          decoration: BoxDecoration(
            color: AssessmentColors.tint(
              context,
              AssessmentColors.motivationTint,
            ),
            borderRadius: BorderRadius.circular(context.ui(18)),
          ),
          child: Row(
            children: [
              Container(
                width: context.ui(48),
                height: context.ui(48),
                decoration: const BoxDecoration(
                  color: AssessmentColors.motivationIcon,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  size: context.ui(26),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: context.ui(AppSpacing.md)),
              Expanded(
                child: Text(
                  quote,
                  style: AppTextStyles.subtitle(context)
                      .copyWith(fontSize: context.ui(12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
