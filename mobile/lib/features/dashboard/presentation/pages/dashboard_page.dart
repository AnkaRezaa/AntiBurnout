import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/date_formatter.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_shortcuts.dart';
import '../widgets/latest_assessment_card.dart';
import '../widgets/motivation_card.dart';

class DashboardPage extends ConsumerWidget {
  final VoidCallback? onStartSurvey;
  final VoidCallback? onViewHistory;
  final VoidCallback? onProfileTap;

  const DashboardPage({
    super.key,
    this.onStartSurvey,
    this.onViewHistory,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    final latest = ref.watch(latestAssessmentProvider);

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: SingleChildScrollView(
          key: const PageStorageKey('dashboard-scroll'),
          padding: EdgeInsets.fromLTRB(
            context.ui(AppSpacing.lg),
            context.ui(AppSpacing.page),
            context.ui(AppSpacing.lg),
            context.ui(AppSpacing.xl),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header
                  DashboardHeader(
                    userName: profile.name,
                    photoUrl: profile.photoUrl,
                    photoBytes: profile.photoBytes,
                    onProfileTap: onProfileTap,
                  ),
                  SizedBox(height: context.ui(AppSpacing.lg)),

                  // 2. Kartu Hasil Asesmen Terakhir
                  LatestAssessmentCard(
                    riskLevel: latest?.riskLevel,
                    date: latest == null
                        ? 'Belum ada asesmen'
                        : formatAssessmentDate(latest.takenAt),
                    onHistoryTap: onViewHistory,
                  ),
                  SizedBox(height: context.ui(AppSpacing.md)),

                  // 3. Tombol Pintasan (Mulai Survei & Riwayat)
                  DashboardShortcuts(
                    onSurveyTap: onStartSurvey,
                    onHistoryTap: onViewHistory,
                  ),
                  SizedBox(height: context.ui(AppSpacing.lg)),

                  // 4. Kartu Motivasi
                  const MotivationCard(),
                  SizedBox(height: context.ui(AppSpacing.md)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
