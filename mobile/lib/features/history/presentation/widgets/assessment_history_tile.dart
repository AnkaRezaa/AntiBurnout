import 'package:flutter/material.dart';

import 'assessment_history_item.dart';

class AssessmentHistoryTile extends StatelessWidget {
  final AssessmentHistoryItem item;
  final bool isLatest;
  final VoidCallback? onDetailTap;

  const AssessmentHistoryTile({
    super.key,
    required this.item,
    this.isLatest = false,
    this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = _RiskStyle.of(item.riskLevel);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onDetailTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ikon risiko
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: style.tint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: style.main, width: 3),
                          ),
                          child: Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: style.main,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Judul, tanggal, keterangan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Risiko Burnout',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.dateTimeLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isLatest
                              ? 'Hasil asesmen terbaru'
                              : 'Hasil asesmen sebelumnya',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Badge dan "Detail"
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: style.badgeBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.riskLevel.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: style.badgeText,
                          ),
                        ),
                      ),
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Detail',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: Color(0xFF6366F1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RiskStyle {
  final Color tint;
  final Color main;
  final Color badgeBg;
  final Color badgeText;

  const _RiskStyle({
    required this.tint,
    required this.main,
    required this.badgeBg,
    required this.badgeText,
  });

  static _RiskStyle of(RiskLevel level) => switch (level) {
        RiskLevel.rendah => const _RiskStyle(
            tint: Color(0xFFE8F7EE),
            main: Color(0xFF22A06B),
            badgeBg: Color(0xFFD7F5E4),
            badgeText: Color(0xFF1F9D5B),
          ),
        RiskLevel.sedang => const _RiskStyle(
            tint: Color(0xFFFFF4DC),
            main: Color(0xFFF5A60B),
            badgeBg: Color(0xFFFFEFC7),
            badgeText: Color(0xFFD97706),
          ),
        RiskLevel.tinggi => const _RiskStyle(
            tint: Color(0xFFFDE8E8),
            main: Color(0xFFE5636B),
            badgeBg: Color(0xFFFDE0E0),
            badgeText: Color(0xFFDC2626),
          ),
      };
}