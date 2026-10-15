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
              'Tema langsung diterapkan dan pilihan diingat selama sesi ini. '
              'Pengingat masih berupa pratinjau.',
          icon: Icons.tune_rounded,
        ),
        SizedBox(height: context.ui(28)),
        Text(
          'Tampilan',
          style: AppTextStyles.title(context)
              .copyWith(fontSize: context.ui(18)),
        ),
        SizedBox(height: context.ui(8)),
        Text(
          'Pilih tema yang paling nyaman untukmu.',
          style: AppTextStyles.subtitle(context)
              .copyWith(fontSize: context.ui(14)),
        ),
        SizedBox(height: context.ui(16)),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth < 300 ||
                MediaQuery.textScalerOf(context).scale(14) > 20;
            final options = [
              for (final option in const [
                (ThemeMode.light, Icons.light_mode_outlined, 'Terang'),
                (ThemeMode.dark, Icons.dark_mode_outlined, 'Gelap'),
                (ThemeMode.system, Icons.brightness_auto_outlined, 'Sistem'),
              ])
                _ThemeOptionCard(
                  key: ValueKey('theme-option-${option.$1.name}'),
                  icon: option.$2,
                  label: option.$3,
                  selected: preferences.themeMode == option.$1,
                  stacked: stacked,
                  onTap: () => controller.setThemeMode(option.$1),
                ),
            ];
            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < options.length; i++) ...[
                    if (i > 0) SizedBox(height: context.ui(10)),
                    options[i],
                  ],
                ],
              );
            }
            return Row(
              children: [
                for (var i = 0; i < options.length; i++) ...[
                  if (i > 0) SizedBox(width: context.ui(10)),
                  Expanded(child: options[i]),
                ],
              ],
            );
          },
        ),
        SizedBox(height: context.ui(30)),
        Text(
          'Pengingat & informasi',
          style: AppTextStyles.title(context)
              .copyWith(fontSize: context.ui(18)),
        ),
        SizedBox(height: context.ui(16)),
        Material(
          color: AppColors.of(context).surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.ui(16)),
            side: BorderSide(color: AppColors.of(context).border),
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
                activeThumbColor: AppColors.of(context).primary,
                contentPadding: EdgeInsets.all(context.ui(16)),
              ),
              Divider(height: 1, color: AppColors.of(context).border),
              SwitchListTile(
                title: const Text('Tips kesehatan mental'),
                subtitle: const Text(
                  'Inspirasi singkat untuk merawat keseharian.',
                ),
                value: preferences.wellbeingTips,
                onChanged: controller.setWellbeingTips,
                activeThumbColor: AppColors.of(context).primary,
                contentPadding: EdgeInsets.all(context.ui(16)),
              ),
            ],
          ),
        ),
        SizedBox(height: context.ui(16)),
        Text(
          'Pengingat dan tips masih berupa contoh antarmuka; belum ada notifikasi yang dikirim.',
          style: AppTextStyles.subtitle(context)
              .copyWith(fontSize: context.ui(12)),
        ),
      ],
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.stacked,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool stacked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(context.ui(14)),
      side: BorderSide(color: selected ? colors.primary : colors.border),
    );
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: AppTextStyles.subtitle(context).copyWith(
        color: selected ? colors.primary : colors.body,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
    final symbol = Icon(
      icon,
      size: context.ui(24),
      color: selected ? colors.primary : colors.body,
    );
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? colors.blob : colors.surface,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.ui(12),
              vertical: context.ui(16),
            ),
            child: stacked
                ? Row(
                    children: [
                      symbol,
                      SizedBox(width: context.ui(12)),
                      Expanded(child: text),
                      if (selected)
                        Icon(Icons.check_rounded, color: colors.primary),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      symbol,
                      SizedBox(height: context.ui(8)),
                      text,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
