import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class DashboardShortcuts extends StatelessWidget {
  const DashboardShortcuts({super.key, this.onSurveyTap, this.onHistoryTap});

  final VoidCallback? onSurveyTap;
  final VoidCallback? onHistoryTap;

  @override
  Widget build(BuildContext context) {
    final survey = _ShortcutCard(
      icon: Icons.check_rounded,
      title: 'Mulai Survei',
      subtitle: 'Lakukan asesmen burnout baru',
      onTap: onSurveyTap,
    );
    final history = _ShortcutCard(
      icon: Icons.menu_rounded,
      title: 'Riwayat Saya',
      subtitle: 'Lihat hasil asesmen sebelumnya',
      onTap: onHistoryTap,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(15) > 21;
        if (constraints.maxWidth < context.ui(280) || largeText) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              survey,
              SizedBox(height: context.ui(AppSpacing.md)),
              history,
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: survey),
              SizedBox(width: context.ui(AppSpacing.md)),
              Expanded(child: history),
            ],
          ),
        );
      },
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.ui(22));
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).surface,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.of(context).shadow,
            blurRadius: context.ui(20),
            offset: Offset(0, context.ui(6)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.all(context.ui(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.ui(44),
                  height: context.ui(44),
                  decoration: BoxDecoration(
                    color: AppColors.of(context).blob,
                    borderRadius: BorderRadius.circular(context.ui(14)),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.of(context).navy,
                    size: context.ui(24),
                  ),
                ),
                SizedBox(height: context.ui(AppSpacing.md)),
                Text(
                  title,
                  style: AppTextStyles.title(context).copyWith(
                    fontSize: context.ui(16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.ui(6)),
                Text(
                  subtitle,
                  style: AppTextStyles.subtitle(context).copyWith(
                    fontSize: context.ui(12),
                    color: AppColors.of(context).hint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
