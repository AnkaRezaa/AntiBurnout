import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary, width: 1.4),
        errorBorder: _border(AppColors.error),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
