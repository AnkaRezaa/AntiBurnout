import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/date_formatter.dart';
import '../../../../shared/widgets/app_blob_background.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_shortcuts.dart';
import '../widgets/latest_assessment_card.dart';
import '../widgets/motivation_card.dart';
import '../widgets/risk_statistics_card.dart';

class DashboardPage extends ConsumerWidget {
  final VoidCallback? onStartSurvey;
  final VoidCallback? onViewHistory;
  final ValueChanged<String>? onViewLatestAssessment;
  final VoidCallback? onProfileTap;

  const DashboardPage({
    super.key,
    this.onStartSurvey,
    this.onViewHistory,
    this.onViewLatestAssessment,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    final latest = ref.watch(latestAssessmentProvider);
    final viewLatestAssessment = onViewLatestAssessment;

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: AppBlobBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            key: const PageStorageKey('dashboard-scroll'),
            padding: EdgeInsets.fromLTRB(
              context.ui(AppSpacing.lg),
              context.ui(AppSpacing.page),
              context.ui(AppSpacing.lg),
              context.ui(AppSpacing.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  onViewResult: latest == null || viewLatestAssessment == null
                      ? null
                      : () => viewLatestAssessment(latest.id),
                ),
                SizedBox(height: context.ui(AppSpacing.md)),

                // 3. Tombol Pintasan (Mulai Survei & Riwayat)
                DashboardShortcuts(
                  onSurveyTap: onStartSurvey,
                  onHistoryTap: onViewHistory,
                ),
                SizedBox(height: context.ui(AppSpacing.lg)),

                RiskStatisticsCard(
                  assessments: ref.watch(dashboardAssessmentsProvider),
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
    );
  }
}
