import 'package:flutter/material.dart';

import '../../core/responsive/app_scale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.prefix,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.obscureText = false,
    this.suffix,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  final String hintText;
  final TextEditingController? controller;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;
  final bool autocorrect;
  final bool enableSuggestions;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          context.ui(AppSpacing.fieldRadius),
        ),
        borderSide: BorderSide(
          color: color,
          width: context.ui(width),
        ),
      );
    }

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      style: TextStyle(
        color: AppColors.navy,
        fontSize: context.ui(16),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.hint,
          fontSize: context.ui(16),
        ),
        filled: true,
        fillColor: AppColors.background,

        // Mengatur ruang di dalam input.
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.ui(16),
          vertical: context.ui(20),
        ),

        prefixIcon: prefix == null
            ? null
            : Padding(
                padding: EdgeInsets.only(
                  left: context.ui(12),
                  right: context.ui(8),
                ),
                child: IconTheme(
                  data: IconThemeData(
                    size: context.ui(24),
                    color: AppColors.hint,
                  ),
                  child: prefix!,
                ),
              ),
        prefixIconConstraints: BoxConstraints(
          minWidth: context.ui(48),
          minHeight: context.ui(48),
        ),

        suffixIcon: suffix,

        border: border(AppColors.border),
        enabledBorder: border(AppColors.border),
        focusedBorder: border(AppColors.primary, width: 1.4),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error, width: 1.4),

        // Pesan validasi dapat menambah tinggi field.
        errorMaxLines: 2,
        errorStyle: TextStyle(
          color: AppColors.error,
          fontSize: context.ui(12),
        ),
      ),
    );
  }
}