import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../widgets/auth_header.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
    this.onSendResetLink,
  });

  // Hubungkan dengan layanan reset password.
  // Future selesai jika permintaan berhasil, throw jika gagal.
  final Future<void> Function(String email)? onSendResetLink;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  bool _isSubmitting = false;
  bool _isSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final sendResetLink = widget.onSendResetLink;

    if (_isSubmitting || sendResetLink == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    final email = _email.text.trim();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await sendResetLink(email);

      if (!mounted) return;

      setState(() {
        _isSent = true;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Permintaan belum berhasil. Silakan coba lagi.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _backToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackdrop(showLeaf: true),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = context.ui(AppSpacing.page);
                final verticalPadding = context.ui(32);

                final minimumHeight = math.max(
                  0.0,
                  constraints.maxHeight - verticalPadding * 2,
                );

                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: minimumHeight,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isSent
                                    ? 'Periksa Emailmu'
                                    : 'Lupa Kata Sandi?',
                                style: AppTextStyles.title.copyWith(
                                  fontSize: context.ui(32),
                                ),
                              ),
                              SizedBox(height: context.ui(12)),
                              Text(
                                _isSent
                                    ? 'Jika email tersebut terdaftar, '
                                        'kamu akan menerima tautan untuk '
                                        'mengatur ulang kata sandi. '
                                        'Periksa juga folder spam.'
                                    : 'Masukkan email yang terdaftar untuk '
                                        'menerima tautan pengaturan ulang '
                                        'kata sandi.',
                                style: AppTextStyles.subtitle.copyWith(
                                  fontSize: context.ui(16),
                                ),
                              ),

                              if (!_isSent) ...[
                                SizedBox(height: context.ui(34)),
                                AbsorbPointer(
                                  absorbing: _isSubmitting,
                                  child: AppTextField(
                                    hintText: 'Email',
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    prefix: Icon(
                                      Icons.alternate_email,
                                      color: AppColors.hint,
                                      size: context.ui(24),
                                    ),
                                    validator: (value) {
                                      final email = value?.trim() ?? '';

                                      if (email.isEmpty) {
                                        return 'Email wajib diisi.';
                                      }

                                      if (!RegExp(
                                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                      ).hasMatch(email)) {
                                        return 'Masukkan email yang valid.';
                                      }

                                      return null;
                                    },
                                  ),
                                ),

                                if (_errorMessage != null) ...[
                                  SizedBox(height: context.ui(12)),
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: context.ui(13),
                                    ),
                                  ),
                                ],

                                SizedBox(height: context.ui(64)),
                                AppButton(
                                  label: 'Kirim Tautan Reset',
                                  isLoading: _isSubmitting,
                                  onPressed: widget.onSendResetLink == null
                                      ? null
                                      : _submit,
                                ),
                              ] else ...[
                                SizedBox(height: context.ui(34)),
                                AppButton(
                                  label: 'Kembali ke Masuk',
                                  onPressed: _backToLogin,
                                ),
                              ],

                              if (!_isSent) ...[
                                SizedBox(height: context.ui(22)),
                                Center(
                                  child: TextButton(
                                    onPressed:
                                        _isSubmitting ? null : _backToLogin,
                                    child: Text(
                                      'Kembali ke Masuk',
                                      style: AppTextStyles.link.copyWith(
                                        fontSize: context.ui(15),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}