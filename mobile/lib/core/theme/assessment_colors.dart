import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic colors shared by assessment results and general guidance.
abstract final class AssessmentColors {
  /// Keep category hues recognizable without using bright cards in dark mode.
  static Color tint(BuildContext context, Color lightTint) {
    if (Theme.of(context).brightness == Brightness.light) return lightTint;
    return Color.alphaBlend(
      lightTint.withValues(alpha: 0.12),
      AppColors.of(context).surface,
    );
  }

  static const riskLow = Color(0xFF2BC751);
  static const riskMedium = Color(0xFFF5A60B);
  static const riskHigh = Color(0xFFE5636B);

  static const sleepTint = Color(0xFFE6F7F0);
  static const activityTint = Color(0xFFE3F3FB);
  static const relaxationTint = Color(0xFFFFF0F0);
  static const socialTint = Color(0xFFF0EBFF);
  static const motivationTint = Color(0xFFEAF1FF);
  static const motivationIcon = Color(0xFF5A8DF8);

  static const disclaimerTint = Color(0xFFFFFAEF);
  static const disclaimerBorder = Color(0xFFFFD58A);
  static const disclaimerIcon = Color(0xFFFFAA0B);
}
