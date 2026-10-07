import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.scale = 1.0,
  }) : assert(scale > 0);

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor:
              AppColors.primary.withValues(alpha: 0.6),

          // Tinggi minimum agar tombol masih dapat membesar
          // jika ukuran teks pengguna memerlukan ruang tambahan.
          minimumSize: Size(
            0,
            (52.0 * scale).clamp(48.0, double.infinity).toDouble(),
          ),

          padding: EdgeInsets.symmetric(
            horizontal: 20.0 * scale,
            vertical: 12.0 * scale,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppSpacing.radius * scale,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.0 * scale,
                height: 22.0 * scale,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4 * scale,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.button.copyWith(
                  fontSize: 16.0 * scale,
                ),
              ),
      ),
    );
  }
}