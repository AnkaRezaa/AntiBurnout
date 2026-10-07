import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/password_text_field.dart';
import '../widgets/auth_header.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ref.read(authControllerProvider.notifier).register(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        );

    if (!mounted) return;

    if (ok) {
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

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
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Buat Akun',
                                style: AppTextStyles.title.copyWith(
                                  color: AppColors.primaryDark,
                                  fontSize: context.ui(32),
                                ),
                              ),
                              SizedBox(height: context.ui(12)),
                              Text(
                                'Daftar untuk mulai menjaga kesehatan '
                                'mentalmu bersama AntiBurnout.',
                                style: AppTextStyles.subtitle.copyWith(
                                  fontSize: context.ui(16),
                                ),
                              ),

                              // Jarak deskripsi ke input pertama.
                              SizedBox(height: context.ui(34)),

                              AppTextField(
                                hintText: 'Nama Lengkap',
                                controller: _name,
                                textInputAction: TextInputAction.next,
                                prefix: Icon(
                                  Icons.person_outline,
                                  color: AppColors.hint,
                                  size: context.ui(24),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Nama lengkap wajib diisi.';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: context.ui(14)),
                              AppTextField(
                                hintText: 'Email',
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                prefix: Icon(
                                  Icons.alternate_email,
                                  color: AppColors.hint,
                                  size: context.ui(24),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      !value.contains('@')) {
                                    return 'Masukkan email yang valid.';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: context.ui(14)),
                              PasswordTextField(
                                hintText: 'Kata Sandi',
                                controller: _password,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.length < 6) {
                                    return 'Kata sandi minimal 6 karakter.';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: context.ui(14)),
                              PasswordTextField(
                                hintText: 'Konfirmasi Kata Sandi',
                                controller: _confirm,
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Konfirmasi kata sandi wajib diisi.';
                                  }
                                  if (value != _password.text) {
                                    return 'Konfirmasi kata sandi tidak sama.';
                                  }
                                  return null;
                                },
                              ),

                              if (auth.errorMessage != null) ...[
                                SizedBox(height: context.ui(12)),
                                Text(
                                  auth.errorMessage!,
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: context.ui(13),
                                  ),
                                ),
                              ],

                              // Jarak input terakhir ke tombol.
                              SizedBox(height: context.ui(64)),

                              AppButton(
                                label: 'Daftar',
                                isLoading: auth.isSubmitting,
                                onPressed: _submit,
                              ),
                              SizedBox(height: context.ui(22)),

                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment:
                                    WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Sudah punya akun?',
                                    style: TextStyle(
                                      color: AppColors.body,
                                      fontSize: context.ui(15),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.go(RoutePaths.login);
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: context.ui(8),
                                        vertical: context.ui(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Masuk',
                                      style: AppTextStyles.link.copyWith(
                                        fontSize: context.ui(15),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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