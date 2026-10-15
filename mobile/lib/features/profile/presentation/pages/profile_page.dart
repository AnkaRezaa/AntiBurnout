import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import 'about_page.dart';
import 'edit_profile_page.dart';
import 'help_page.dart';
import 'personalization_page.dart';
import 'preferences_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    super.key,
    this.onEditProfile,
    this.onPreferences,
    this.onHelp,
    this.onAbout,
    this.onPersonalization,
  });

  final VoidCallback? onEditProfile;
  final VoidCallback? onPreferences;
  final VoidCallback? onHelp;
  final VoidCallback? onAbout;
  final VoidCallback? onPersonalization;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoggingOut = false;
  String? _localPage;

  void _openPage(String page, VoidCallback? onOpen) {
    if (onOpen != null) {
      onOpen();
    } else {
      setState(() => _localPage = page);
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).logout();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal keluar. Silakan coba lagi.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void closeLocalPage() => setState(() => _localPage = null);
    switch (_localPage) {
      case 'edit':
        return EditProfilePage(onBack: closeLocalPage);
      case 'preferences':
        return PreferencesPage(onBack: closeLocalPage);
      case 'help':
        return HelpPage(onBack: closeLocalPage);
      case 'about':
        return AboutPage(onBack: closeLocalPage);
      case 'personalization':
        return PersonalizationPage(onBack: closeLocalPage);
    }

    final profile = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            context.ui(24),
            context.ui(28),
            context.ui(24),
            context.ui(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Profil',
                style: AppTextStyles.title(context).copyWith(
                  color: AppColors.of(context).navy,
                  fontSize: context.ui(24),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: context.ui(26)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    size: 98,
                    photoUrl: profile.photoUrl,
                    photoBytes: profile.photoBytes,
                  ),
                  SizedBox(width: context.ui(14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: AppTextStyles.title(context).copyWith(
                            color: AppColors.of(context).navy,
                            fontSize: context.ui(20),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: context.ui(8)),
                        Text(
                          profile.email,
                          style: AppTextStyles.subtitle(context).copyWith(
                            color: AppColors.of(context).hint,
                            fontSize: context.ui(14),
                          ),
                        ),
                        SizedBox(height: context.ui(12)),
                        TextButton(
                          onPressed: () {
                            _openPage('edit', widget.onEditProfile);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.of(context).primary,
                            backgroundColor: AppColors.of(context).blob,
                            minimumSize: Size(context.ui(100), context.ui(40)),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.ui(18),
                              vertical: context.ui(6),
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            'Edit Profil',
                            style: AppTextStyles.link(context).copyWith(
                              color: AppColors.of(context).primary,
                              fontSize: context.ui(14),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.ui(28)),
              Material(
                color: AppColors.of(context).surface,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.ui(16)),
                  side: BorderSide(color: AppColors.of(context).border),
                ),
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Personalisasi Profil',
                      onTap: () {
                        _openPage('personalization', widget.onPersonalization);
                      },
                    ),
                    const _ProfileDivider(),
                    _ProfileMenuItem(
                      icon: Icons.settings_outlined,
                      label: 'Preferensi',
                      onTap: () {
                        _openPage('preferences', widget.onPreferences);
                      },
                    ),
                    const _ProfileDivider(),
                    _ProfileMenuItem(
                      icon: Icons.question_mark_rounded,
                      label: 'Bantuan',
                      onTap: () {
                        _openPage('help', widget.onHelp);
                      },
                    ),
                    const _ProfileDivider(),
                    _ProfileMenuItem(
                      icon: Icons.info_outline_rounded,
                      label: 'Tentang Aplikasi',
                      onTap: () {
                        _openPage('about', widget.onAbout);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.ui(28)),
              OutlinedButton(
                onPressed: _isLoggingOut ? null : _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.of(context).error,
                  minimumSize: Size(
                    double.infinity,
                    context.ui(50).clamp(48.0, double.infinity).toDouble(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.ui(20),
                    vertical: context.ui(14),
                  ),
                  side: BorderSide(
                    color: AppColors.of(context).error,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.ui(14)),
                  ),
                ),
                child: _isLoggingOut
                    ? SizedBox(
                        width: context.ui(22),
                        height: context.ui(22),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.of(context).error,
                        ),
                      )
                    : Text(
                        'Keluar',
                        style: TextStyle(
                          fontSize: context.ui(16),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: context.ui(56).clamp(48.0, double.infinity).toDouble(),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.ui(20),
            vertical: context.ui(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.of(context).navy,
                size: context.ui(24),
              ),
              SizedBox(width: context.ui(16)),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.subtitle(context).copyWith(
                    color: AppColors.of(context).navy,
                    fontSize: context.ui(16),
                  ),
                ),
              ),
              SizedBox(width: context.ui(8)),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.of(context).hint,
                size: context.ui(24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.of(context).border,
    );
  }
}
