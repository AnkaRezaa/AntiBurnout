import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/user_avatar.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userName,
    this.photoUrl,
    this.photoBytes,
    this.onProfileTap,
    this.subtitle = 'Jaga kesehatan mentalmu, mulai dari sekarang.',
  });

  final String userName;
  final String? photoUrl;
  final Uint8List? photoBytes;
  final VoidCallback? onProfileTap;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo,',
                    style: AppTextStyles.subtitle(context).copyWith(
                      fontSize: context.ui(18),
                      color: AppColors.of(context).navy,
                    ),
                  ),
                  SizedBox(height: context.ui(AppSpacing.xs)),
                  Text(
                    '$userName!',
                    style: AppTextStyles.title(context)
                        .copyWith(fontSize: context.ui(24)),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.ui(AppSpacing.md)),
            IconButton(
              tooltip: 'Buka profil',
              onPressed: onProfileTap,
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(48, 48),
              ),
              icon: ExcludeSemantics(
                child: UserAvatar(photoUrl: photoUrl, photoBytes: photoBytes),
              ),
            ),
          ],
        ),
        SizedBox(height: context.ui(AppSpacing.md)),
        Text(
          subtitle,
          style: AppTextStyles.subtitle(context)
              .copyWith(fontSize: context.ui(15)),
        ),
      ],
    );
  }
}
