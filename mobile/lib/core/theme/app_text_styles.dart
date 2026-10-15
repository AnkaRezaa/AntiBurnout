import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle title(BuildContext context) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.of(context).navy,
    height: 1.2,
  );

  static TextStyle brand(BuildContext context) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.of(context).navy,
    height: 1.1,
  );

  static TextStyle subtitle(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.of(context).body,
    height: 1.5,
  );

  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.of(context).onPrimary,
  );

  static TextStyle link(BuildContext context) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.of(context).primary,
  );
}
