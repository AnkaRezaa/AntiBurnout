import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
    this.textInputAction,
  });

  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hintText: widget.hintText,
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      prefix: const Text(
        '*',
        style: TextStyle(
          color: AppColors.hint,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
      suffix: IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.circle : Icons.circle_outlined,
          size: 14,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
