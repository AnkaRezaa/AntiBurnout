import 'package:flutter/material.dart';

import '../../core/responsive/app_scale.dart';
import '../../core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.photoUrl, this.size = 48});

  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final diameter = context.ui(size);
    final url = photoUrl?.trim();

    Widget fallback() => Image.asset(
      'assets/images/profile-male.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.person_outline_rounded,
        color: AppColors.navy,
        size: diameter * 0.6,
      ),
    );

    return Semantics(
      image: true,
      label: 'Avatar pengguna',
      child: Container(
        width: diameter,
        height: diameter,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.background,
          border: Border.all(color: AppColors.blob),
        ),
        child: ClipOval(
          child: url == null || url.isEmpty
              ? fallback()
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : fallback(),
                  errorBuilder: (context, error, stackTrace) => fallback(),
                ),
        ),
      ),
    );
  }
}
