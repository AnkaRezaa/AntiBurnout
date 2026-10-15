import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/assessment_colors.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color backgroundColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.ui(AppSpacing.md)),
      decoration: BoxDecoration(
        color: AssessmentColors.tint(context, backgroundColor),
        borderRadius: BorderRadius.circular(context.ui(AppSpacing.radius)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: context.ui(46),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          SizedBox(width: context.ui(AppSpacing.md)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title(context).copyWith(
                    fontSize: context.ui(15),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.ui(AppSpacing.xs)),
                Text(
                  body,
                  style: AppTextStyles.subtitle(context)
                      .copyWith(fontSize: context.ui(13), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
