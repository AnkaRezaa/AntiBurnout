import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_shortcuts.dart';
import '../widgets/latest_assessment_card.dart';
import '../widgets/motivation_card.dart';

class DashboardPage extends ConsumerWidget {
  final VoidCallback? onStartSurvey;
  final VoidCallback? onViewHistory;

  const DashboardPage({
    super.key,
    this.onStartSurvey,
    this.onViewHistory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final displayName = user?.name ?? 'Esatovin';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              DashboardHeader(userName: displayName),
              const SizedBox(height: 24),

              // 2. Kartu Hasil Asesmen Terakhir
              LatestAssessmentCard(
                riskLevel: 'Sedang',
                date: '18 September 2026',
                onDetailTap: () {
                  // Arahkan ke halaman detail hasil asesmen
                },
              ),
              const SizedBox(height: 20),

              // 3. Tombol Pintasan (Mulai Survei & Riwayat)
              DashboardShortcuts(
                onSurveyTap: onStartSurvey,
                onHistoryTap: onViewHistory,
              ),
              const SizedBox(height: 24),

              // 4. Kartu Motivasi
              const MotivationCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
