import 'package:flutter/material.dart';

import '../../core/responsive/app_scale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.of(context).primary,
          foregroundColor: AppColors.of(context).onPrimary,
          disabledBackgroundColor: AppColors.of(context).primary
              .withValues(alpha: 0.6),

          // Tinggi minimum 48; dapat bertambah mengikuti ukuran teks.
          minimumSize: Size(
            0,
            context.ui(52).clamp(48.0, double.infinity).toDouble(),
          ),

          padding: EdgeInsets.symmetric(
            horizontal: context.ui(20),
            vertical: context.ui(12),
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.ui(AppSpacing.radius)),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: context.ui(22),
                height: context.ui(22),
                child: CircularProgressIndicator(
                  strokeWidth: context.ui(2.4),
                  color: AppColors.of(context).onPrimary,
                ),
              )
            : Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.button(context)
                    .copyWith(fontSize: context.ui(16)),
              ),
      ),
    );
  }
}
