import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/assessment_colors.dart';

class EncouragementCard extends StatelessWidget {
  const EncouragementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.ui(AppSpacing.md)),
      decoration: BoxDecoration(
        color: AssessmentColors.tint(context, AssessmentColors.motivationTint),
        borderRadius: BorderRadius.circular(context.ui(AppSpacing.radius)),
      ),
      child: Row(
        children: [
          Container(
            width: context.ui(48),
            height: context.ui(48),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AssessmentColors.motivationIcon,
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: Colors.white,
              size: context.ui(26),
            ),
          ),
          SizedBox(width: context.ui(AppSpacing.md)),
          Expanded(
            child: Text(
              'Prioritaskan kesehatan mentalmu.',
              style: AppTextStyles.subtitle(context)
                  .copyWith(fontSize: context.ui(13)),
            ),
          ),
        ],
      ),
    );
  }
}
