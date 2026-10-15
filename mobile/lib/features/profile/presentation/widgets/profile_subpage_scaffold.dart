import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_page_header.dart';

class ProfileSubpageScaffold extends StatelessWidget {
  const ProfileSubpageScaffold({
    super.key,
    required this.title,
    required this.onBack,
    required this.children,
  });

  final String title;
  final VoidCallback onBack;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(title: title, onBack: onBack, fontSize: 22),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  context.ui(24),
                  context.ui(24),
                  context.ui(24),
                  context.ui(32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.text,
    this.icon = Icons.info_outline_rounded,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.ui(16)),
      decoration: BoxDecoration(
        color: AppColors.of(context).blob.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(context.ui(16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.of(context).primary,
            size: context.ui(22),
          ),
          SizedBox(width: context.ui(12)),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.subtitle(context)
                  .copyWith(fontSize: context.ui(13)),
            ),
          ),
        ],
      ),
    );
  }
}
