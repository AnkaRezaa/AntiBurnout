import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/profile_subpage_scaffold.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ProfileSubpageScaffold(
      title: 'Tentang Aplikasi',
      onBack: onBack,
      children: [
        Container(
          padding: EdgeInsets.all(context.ui(24)),
          decoration: BoxDecoration(
            color: AppColors.of(context).blob.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(context.ui(24)),
          ),
          child: Column(
            children: [
              Container(
                width: context.ui(72),
                height: context.ui(72),
                decoration: BoxDecoration(
                  color: AppColors.of(context).primary,
                  borderRadius: BorderRadius.circular(context.ui(22)),
                ),
                child: Icon(
                  Icons.spa_outlined,
                  color: AppColors.of(context).onPrimary,
                  size: context.ui(38),
                ),
              ),
              SizedBox(height: context.ui(18)),
              Text(
                'AntiBurnout',
                style: AppTextStyles.brand(context)
                    .copyWith(fontSize: context.ui(28)),
              ),
              SizedBox(height: context.ui(6)),
              Text(
                'Kenali dirimu. Jaga keseimbanganmu.',
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle(context)
                    .copyWith(fontSize: context.ui(14)),
              ),
              SizedBox(height: context.ui(10)),
              Text(
                'Versi 1.0.0',
                style: AppTextStyles.subtitle(context)
                    .copyWith(fontSize: context.ui(12)),
              ),
            ],
          ),
        ),
        SizedBox(height: context.ui(28)),
        Text(
          'Tentang AntiBurnout',
          style: AppTextStyles.title(context)
              .copyWith(fontSize: context.ui(18)),
        ),
        SizedBox(height: context.ui(10)),
        Text(
          'AntiBurnout membantu pengguna mengenali kondisi diri melalui '
          'asesmen mandiri, melihat riwayat hasil, dan menemukan panduan '
          'umum untuk menjaga keseimbangan aktivitas sehari-hari.',
          style: AppTextStyles.subtitle(context)
              .copyWith(fontSize: context.ui(14)),
        ),
        SizedBox(height: context.ui(24)),
        for (final feature in const [
          (
            Icons.assignment_outlined,
            'Asesmen mandiri',
            'Refleksikan kebiasaan dan kondisi melalui pertanyaan singkat.',
          ),
          (
            Icons.history_rounded,
            'Riwayat asesmen',
            'Telusuri kembali hasil dan ringkasan asesmen sebelumnya.',
          ),
          (
            Icons.favorite_border_rounded,
            'Panduan keseharian',
            'Temukan ide untuk istirahat, relaksasi, dan dukungan sosial.',
          ),
        ]) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(context.ui(11)),
                decoration: BoxDecoration(
                  color: AppColors.of(context).blob,
                  borderRadius: BorderRadius.circular(context.ui(12)),
                ),
                child: Icon(feature.$1, color: AppColors.of(context).primary),
              ),
              SizedBox(width: context.ui(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.$2,
                      style: AppTextStyles.subtitle(context).copyWith(
                        color: AppColors.of(context).navy,
                        fontWeight: FontWeight.w600,
                        fontSize: context.ui(14),
                      ),
                    ),
                    SizedBox(height: context.ui(4)),
                    Text(
                      feature.$3,
                      style: AppTextStyles.subtitle(context)
                          .copyWith(fontSize: context.ui(13)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.ui(20)),
        ],
        const ProfileInfoCard(
          text:
              'Hasil asesmen bukan diagnosis medis. '
              'Aplikasi ini tidak menggantikan konsultasi dengan tenaga profesional.',
        ),
        SizedBox(height: context.ui(28)),
        Text(
          'Dikembangkan oleh Tim AntiBurnout',
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle(context)
              .copyWith(fontSize: context.ui(13)),
        ),
        SizedBox(height: context.ui(6)),
        Text(
          '© 2026 AntiBurnout',
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle(context).copyWith(
            color: AppColors.of(context).hint,
            fontSize: context.ui(12),
          ),
        ),
      ],
    );
  }
}
