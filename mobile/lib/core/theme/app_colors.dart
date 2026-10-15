import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF6B67F0);
  static const primaryDark = Color(0xFF5A56D6);
  static const navy = Color(0xFF52669F);
  static const body = Color(0xFF6B7394);
  static const hint = Color(0xFF9AA3B8);
  static const border = Color(0xFFE4E7F1);
  static const background = Color(0xFFFFFFFF);
  static const blob = Color(0xFFE8EEFF);
  static const leaf = Color(0xFF8FD4C8);
  static const error = Color(0xFFE53935);

  static AppPalette of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark
            ? AppPalette.dark
            : AppPalette.light);
  }
}

/// Semantic colors shared by both themes and animated by MaterialApp.
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.primaryDark,
    required this.onPrimary,
    required this.navy,
    required this.body,
    required this.hint,
    required this.border,
    required this.background,
    required this.surface,
    required this.blob,
    required this.leaf,
    required this.error,
    required this.disabledSurface,
    required this.shadow,
  });

  static const light = AppPalette(
    primary: AppColors.primary,
    primaryDark: AppColors.primaryDark,
    onPrimary: Colors.white,
    navy: AppColors.navy,
    body: AppColors.body,
    hint: AppColors.hint,
    border: AppColors.border,
    background: AppColors.background,
    surface: Colors.white,
    blob: AppColors.blob,
    leaf: AppColors.leaf,
    error: AppColors.error,
    disabledSurface: AppColors.border,
    shadow: Color(0x1252669F),
  );

  static const dark = AppPalette(
    primary: Color(0xFFB7B0FF),
    primaryDark: Color(0xFFCCC7FF),
    onPrimary: Color(0xFF211B48),
    navy: Color(0xFFE7EBFF),
    body: Color(0xFFC0C9DD),
    hint: Color(0xFFA0ABC1),
    border: Color(0xFF39435A),
    background: Color(0xFF101522),
    surface: Color(0xFF1A2132),
    blob: Color(0xFF282F4B),
    leaf: Color(0xFF9BDED0),
    error: Color(0xFFFF9AA2),
    disabledSurface: Color(0xFF293144),
    shadow: Color(0x33000000),
  );

  final Color primary;
  final Color primaryDark;
  final Color onPrimary;
  final Color navy;
  final Color body;
  final Color hint;
  final Color border;
  final Color background;
  final Color surface;
  final Color blob;
  final Color leaf;
  final Color error;
  final Color disabledSurface;
  final Color shadow;

  @override
  AppPalette copyWith({
    Color? primary,
    Color? primaryDark,
    Color? onPrimary,
    Color? navy,
    Color? body,
    Color? hint,
    Color? border,
    Color? background,
    Color? surface,
    Color? blob,
    Color? leaf,
    Color? error,
    Color? disabledSurface,
    Color? shadow,
  }) => AppPalette(
    primary: primary ?? this.primary,
    primaryDark: primaryDark ?? this.primaryDark,
    onPrimary: onPrimary ?? this.onPrimary,
    navy: navy ?? this.navy,
    body: body ?? this.body,
    hint: hint ?? this.hint,
    border: border ?? this.border,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    blob: blob ?? this.blob,
    leaf: leaf ?? this.leaf,
    error: error ?? this.error,
    disabledSurface: disabledSurface ?? this.disabledSurface,
    shadow: shadow ?? this.shadow,
  );

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      navy: Color.lerp(navy, other.navy, t)!,
      body: Color.lerp(body, other.body, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      border: Color.lerp(border, other.border, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      blob: Color.lerp(blob, other.blob, t)!,
      leaf: Color.lerp(leaf, other.leaf, t)!,
      error: Color.lerp(error, other.error, t)!,
      disabledSurface: Color.lerp(disabledSurface, other.disabledSurface, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}
