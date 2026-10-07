import 'package:flutter/material.dart';

class DashboardShortcuts extends StatelessWidget {
  final VoidCallback? onSurveyTap;
  final VoidCallback? onHistoryTap;

  const DashboardShortcuts({
    super.key,
    this.onSurveyTap,
    this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Card 1: Mulai Survei
        Expanded(
          child: _ShortcutCard(
            icon: Icons.check_rounded,
            title: 'Mulai Survei',
            subtitle: 'Lakukan asesmen burnout baru',
            onTap: onSurveyTap,
          ),
        ),
        const SizedBox(width: 14),

        // Card 2: Riwayat Saya
        Expanded(
          child: _ShortcutCard(
            icon: Icons.menu_rounded,
            title: 'Riwayat Saya',
            subtitle: 'Lihat hasil asesmen sebelumnya',
            onTap: onHistoryTap,
          ),
        ),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2563EB),
                size: 22,
              ),
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
