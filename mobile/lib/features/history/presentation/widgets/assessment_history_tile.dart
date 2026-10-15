import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/assessment_colors.dart';
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
    final colors = AppColors.of(context);
    final style = _RiskStyle.of(context, item.riskLevel);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                        Text(
                          'Risiko Burnout',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: colors.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.dateTimeLabel,
                          style: TextStyle(fontSize: 11, color: colors.hint),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isLatest
                              ? 'Hasil asesmen terbaru'
                              : 'Hasil asesmen sebelumnya',
                          style: TextStyle(fontSize: 11, color: colors.body),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Detail',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: colors.primary,
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

  static _RiskStyle of(BuildContext context, RiskLevel level) {
    final style = switch (level) {
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
    if (Theme.of(context).brightness == Brightness.light) return style;
    final riskColor = switch (level) {
      RiskLevel.rendah => AssessmentColors.riskLow,
      RiskLevel.sedang => AssessmentColors.riskMedium,
      RiskLevel.tinggi => AssessmentColors.riskHigh,
    };
    return _RiskStyle(
      tint: AssessmentColors.tint(context, style.tint),
      main: riskColor,
      badgeBg: AssessmentColors.tint(context, style.badgeBg),
      badgeText: riskColor,
    );
  }
}
