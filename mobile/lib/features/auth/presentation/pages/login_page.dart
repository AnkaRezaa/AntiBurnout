import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/auth_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AuthBackdrop(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => context.go(RoutePaths.welcome),
                    icon: const Icon(Icons.chevron_left, color: AppColors.navy),
                  ),
                  const SizedBox(height: 12),
                  const AuthHeader(
                    title: 'Selamat Datang!',
                    subtitle:
                        'Masuk untuk melanjutkan perjalanan menuju versi terbaik dirimu.',
                  ),
                  const Spacer(),
                  const Center(
                    child: Text(
                      'Halaman login akan dikerjakan berikutnya.',
                      style: TextStyle(color: AppColors.body, fontSize: 13),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun? ',
                        style: TextStyle(color: AppColors.body, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => context.go(RoutePaths.register),
                        child: const Text('Daftar', style: AppTextStyles.link),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
