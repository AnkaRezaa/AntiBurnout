import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoggingOut = false;

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature belum tersedia.'),
        ),
      );
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
        const SnackBar(
          content: Text('Gagal keluar. Silakan coba lagi.'),
        ),
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
    final user = ref.watch(authControllerProvider).user;
    final name = user?.name ?? 'Pengguna';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
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
                style: AppTextStyles.title.copyWith(
                  color: AppColors.navy,
                  fontSize: context.ui(24),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: context.ui(26)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/profile-male.png',
                    width: context.ui(98),
                    height: context.ui(98),
                    fit: BoxFit.contain,
                    semanticLabel: 'Avatar pengguna',
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: context.ui(104),
                        height: context.ui(104),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEEF1FF),
                          border: Border.all(
                            color: const Color(0xFFE0E6F2),
                          ),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: context.ui(48),
                          color: AppColors.hint,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: context.ui(14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.title.copyWith(
                            color: AppColors.navy,
                            fontSize: context.ui(20),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: context.ui(8)),
                        Text(
                          email,
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.hint,
                            fontSize: context.ui(14),
                          ),
                        ),
                        SizedBox(height: context.ui(12)),
                        TextButton(
                          onPressed: () {
                            _showComingSoon('Edit Profil');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            backgroundColor: const Color(0xFFEEF0FF),
                            minimumSize: Size(
                              context.ui(100),
                              context.ui(40),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.ui(18),
                              vertical: context.ui(6),
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            'Edit Profil',
                            style: AppTextStyles.link.copyWith(
                              color: AppColors.primary,
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
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.ui(16)),
                  side: const BorderSide(
                    color: Color(0xFFE0E6F2),
                  ),
                ),
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.person_outline_rounded,
                      iconColor: Colors.black,
                      label: 'Personalisasi Profil',
                      onTap: () {
                        _showComingSoon('Personalisasi Profil');
                      },
                    ),
                    const _ProfileDivider(),
                    _ProfileMenuItem(
                      icon: Icons.settings_outlined,
                      iconColor: Colors.black,
                      label: 'Preferensi',
                      onTap: () {
                        _showComingSoon('Preferensi');
                      },
                    ),
                    const _ProfileDivider(),
                    _ProfileMenuItem(
                      icon: Icons.question_mark_rounded,
                      label: 'Bantuan',
                      onTap: () {
                        _showComingSoon('Bantuan');
                      },
                    ),
                    const _ProfileDivider(),
                    _ProfileMenuItem(
                      icon: Icons.info_outline_rounded,
                      label: 'Tentang Aplikasi',
                      onTap: () {
                        _showComingSoon('Tentang Aplikasi');
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.ui(28)),
              OutlinedButton(
                onPressed: _isLoggingOut ? null : _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF526B),
                  minimumSize: Size(
                    double.infinity,
                    context.ui(50).clamp(48.0, double.infinity).toDouble(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.ui(20),
                    vertical: context.ui(14),
                  ),
                  side: const BorderSide(
                    color: Color(0xFFFF526B),
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
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF526B),
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
    this.iconColor = AppColors.navy,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;

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
                color: iconColor,
                size: context.ui(24),
              ),
              SizedBox(width: context.ui(16)),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.navy,
                    fontSize: context.ui(16),
                  ),
                ),
              ),
              SizedBox(width: context.ui(8)),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.hint,
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
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE5E9F2),
    );
  }
}