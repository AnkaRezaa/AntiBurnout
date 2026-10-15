import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colors = brightness == Brightness.dark
        ? AppPalette.dark
        : AppPalette.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [colors],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        surface: colors.surface,
        onSurface: colors.navy,
        onSurfaceVariant: colors.body,
        outline: colors.border,
        error: colors.error,
      ),
      scaffoldBackgroundColor: colors.background,
      dividerColor: colors.border,
      iconTheme: IconThemeData(color: colors.body),
      fontFamily: 'Roboto',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        hintStyle: TextStyle(color: colors.hint, fontSize: 14),
        labelStyle: TextStyle(color: colors.body),
        helperStyle: TextStyle(color: colors.body),
        prefixIconColor: colors.hint,
        suffixIconColor: colors.hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: _border(colors.border),
        enabledBorder: _border(colors.border),
        disabledBorder: _border(colors.border),
        focusedBorder: _border(colors.primary, width: 1.4),
        errorBorder: _border(colors.error),
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
