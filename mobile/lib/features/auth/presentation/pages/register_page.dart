import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_header.dart';
import '../widgets/password_text_field.dart';

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
          name: _name.text,
          email: _email.text,
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
      body: Stack(
        children: [
          const AuthBackdrop(showLeaf: true),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go(RoutePaths.welcome),
                    icon: const Icon(Icons.chevron_left, color: AppColors.navy),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AuthHeader(
                            title: 'Buat Akun',
                            subtitle:
                                'Daftar untuk mulai menjaga kesehatan mentalmu bersama AntiBurnout.',
                          ),
                          const SizedBox(height: 28),
                          AppTextField(
                            hintText: 'Nama Lengkap',
                            controller: _name,
                            textInputAction: TextInputAction.next,
                            prefix: const Icon(Icons.person_outline, color: AppColors.hint),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama lengkap wajib diisi.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            hintText: 'Email',
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefix: const Icon(Icons.alternate_email, color: AppColors.hint),
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return 'Masukkan email yang valid.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
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
                          const SizedBox(height: 14),
                          PasswordTextField(
                            hintText: 'Konfirmasi Kata Sandi',
                            controller: _confirm,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value != _password.text) {
                                return 'Konfirmasi kata sandi tidak sama.';
                              }
                              return null;
                            },
                          ),
                          if (auth.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              auth.errorMessage!,
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ],
                          const SizedBox(height: 28),
                          AppButton(
                            label: 'Daftar',
                            isLoading: auth.isSubmitting,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Sudah punya akun? ',
                                style: TextStyle(color: AppColors.body, fontSize: 13),
                              ),
                              GestureDetector(
                                onTap: () => context.go(RoutePaths.login),
                                child: const Text('Masuk', style: AppTextStyles.link),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
