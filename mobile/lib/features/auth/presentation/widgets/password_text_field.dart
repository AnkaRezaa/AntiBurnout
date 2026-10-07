import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
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

      // Tetap nonaktif meskipun password sedang ditampilkan.
      autocorrect: false,
      enableSuggestions: false,

      // Ukuran ikon mengikuti IconTheme dari AppTextField.
      prefix: const Icon(
        Icons.lock_outline_rounded,
        color: AppColors.hint,
      ),

      suffix: IconButton(
        tooltip: _obscure
            ? 'Tampilkan kata sandi'
            : 'Sembunyikan kata sandi',
        padding: EdgeInsets.all(context.ui(12)),
        constraints: BoxConstraints(
          minWidth:
              context.ui(48).clamp(48.0, double.infinity).toDouble(),
          minHeight:
              context.ui(48).clamp(48.0, double.infinity).toDouble(),
        ),
        onPressed: () {
          setState(() {
            _obscure = !_obscure;
          });
        },
        icon: Icon(
          _obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.primary,
          size: context.ui(22),
        ),
      ),
    );
  }
}