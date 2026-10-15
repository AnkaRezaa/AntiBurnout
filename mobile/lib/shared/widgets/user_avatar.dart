import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/responsive/app_scale.dart';
import '../../core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.photoUrl, this.photoBytes, this.size = 48});

  final String? photoUrl;
  final Uint8List? photoBytes;
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
        color: AppColors.of(context).navy,
        size: diameter * 0.6,
      ),
    );

    Widget networkOrFallback() => url == null || url.isEmpty
        ? fallback()
        : Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : fallback(),
            errorBuilder: (context, error, stackTrace) => fallback(),
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
          color: AppColors.of(context).surface,
          border: Border.all(color: AppColors.of(context).blob),
        ),
        child: ClipOval(
          child: photoBytes != null
              ? Image.memory(
                  photoBytes!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      networkOrFallback(),
                )
              : networkOrFallback(),
        ),
      ),
    );
  }
}
