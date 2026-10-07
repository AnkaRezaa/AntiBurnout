import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${user?.name ?? 'Pengguna'}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? '',
                style: const TextStyle(color: AppColors.body),
              ),
              const Spacer(),
              AppButton(
                label: 'Keluar',
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
