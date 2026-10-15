import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/preferences_controller.dart';
import '../widgets/profile_subpage_scaffold.dart';

class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesControllerProvider);
    final controller = ref.read(preferencesControllerProvider.notifier);

    return ProfileSubpageScaffold(
      title: 'Preferensi',
      onBack: onBack,
      children: [
        const ProfileInfoCard(
          text:
              'Pratinjau preferensi. Pilihan diingat selama sesi ini. '
              'Tema dan notifikasi belum diterapkan.',
          icon: Icons.tune_rounded,
        ),
        SizedBox(height: context.ui(28)),
        Text(
          'Tampilan',
          style: AppTextStyles.title.copyWith(fontSize: context.ui(18)),
        ),
        SizedBox(height: context.ui(8)),
        Text(
          'Pilih tema yang paling nyaman untukmu.',
          style: AppTextStyles.subtitle.copyWith(fontSize: context.ui(14)),
        ),
        SizedBox(height: context.ui(16)),
        Wrap(
          spacing: context.ui(10),
          runSpacing: context.ui(10),
          children: [
            for (final option in const [
              (ThemeMode.light, Icons.light_mode_outlined, 'Terang'),
              (ThemeMode.dark, Icons.dark_mode_outlined, 'Gelap'),
              (ThemeMode.system, Icons.brightness_auto_outlined, 'Sistem'),
            ])
              ChoiceChip(
                avatar: Icon(option.$2, size: context.ui(18)),
                label: Text(option.$3),
                selected: preferences.themeMode == option.$1,
                onSelected: (_) => controller.setThemeMode(option.$1),
                selectedColor: AppColors.blob,
                showCheckmark: false,
                padding: EdgeInsets.symmetric(
                  horizontal: context.ui(10),
                  vertical: context.ui(12),
                ),
                side: BorderSide(
                  color: preferences.themeMode == option.$1
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
          ],
        ),
        SizedBox(height: context.ui(30)),
        Text(
          'Pengingat & informasi',
          style: AppTextStyles.title.copyWith(fontSize: context.ui(18)),
        ),
        SizedBox(height: context.ui(16)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.ui(16)),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Pengingat harian'),
                subtitle: const Text(
                  'Luangkan waktu untuk memeriksa kondisi diri.',
                ),
                value: preferences.dailyReminder,
                onChanged: controller.setDailyReminder,
                activeThumbColor: AppColors.primary,
                contentPadding: EdgeInsets.all(context.ui(16)),
              ),
              const Divider(height: 1, color: AppColors.border),
              SwitchListTile(
                title: const Text('Tips kesehatan mental'),
                subtitle: const Text(
                  'Inspirasi singkat untuk merawat keseharian.',
                ),
                value: preferences.wellbeingTips,
                onChanged: controller.setWellbeingTips,
                activeThumbColor: AppColors.primary,
                contentPadding: EdgeInsets.all(context.ui(16)),
              ),
            ],
          ),
        ),
        SizedBox(height: context.ui(16)),
        Text(
          'Kontrol di halaman ini hanya contoh antarmuka; belum ada notifikasi yang dikirim.',
          style: AppTextStyles.subtitle.copyWith(fontSize: context.ui(12)),
        ),
      ],
    );
  }
}
