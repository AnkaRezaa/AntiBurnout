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
import '../widgets/auth_header.dart';
import '../widgets/password_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (ref.read(authControllerProvider).isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    final ok = await ref.read(authControllerProvider.notifier).login(
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
                                'Selamat Datang!',
                                textAlign: TextAlign.left,
                                style: AppTextStyles.title.copyWith(
                                  color: AppColors.primaryDark,
                                  fontSize: context.ui(32),
                                ),
                              ),
                              SizedBox(height: context.ui(28)),
                              Text(
                                'Masuk untuk melanjutkan perjalanan '
                                'menuju versi terbaik dirimu.',
                                textAlign: TextAlign.left,
                                style: AppTextStyles.subtitle.copyWith(
                                  fontSize: context.ui(16),
                                ),
                              ),

                              // Jarak deskripsi ke form mengikuti mockup.
                              SizedBox(height: context.ui(56)),

                              AppTextField(
                                hintText: 'Email',
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
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

                                  if (!email.contains('@')) {
                                    return 'Masukkan email yang valid.';
                                  }

                                  return null;
                                },
                              ),
                              SizedBox(height: context.ui(28)),
                              PasswordTextField(
                                hintText: 'Kata Sandi',
                                controller: _password,
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Kata sandi wajib diisi.';
                                  }

                                  return null;
                                },
                              ),

                              SizedBox(height: context.ui(20)),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: auth.isSubmitting
                                      ? null
                                      : () {
                                          context.push(
                                            RoutePaths.forgotPassword,
                                          );
                                        },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: context.ui(4),
                                      vertical: context.ui(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Lupa kata sandi?',
                                    style: AppTextStyles.link.copyWith(
                                      fontSize: context.ui(14),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
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

                              SizedBox(height: context.ui(32)),

                              AppButton(
                                label: 'Masuk',
                                isLoading: auth.isSubmitting,
                                onPressed: _submit,
                              ),

                              SizedBox(height: context.ui(32)),

                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Belum punya akun?',
                                    style: TextStyle(
                                      color: AppColors.body,
                                      fontSize: context.ui(15),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: auth.isSubmitting
                                        ? null
                                        : () {
                                            context.go(RoutePaths.register);
                                          },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: context.ui(8),
                                        vertical: context.ui(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Daftar',
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