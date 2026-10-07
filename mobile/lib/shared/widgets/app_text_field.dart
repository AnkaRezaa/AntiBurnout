import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

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
  });

  final String hintText;
  final TextEditingController? controller;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: AppColors.navy, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefix == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: prefix,
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        suffixIcon: suffix,
      ),
    );
  }
}
