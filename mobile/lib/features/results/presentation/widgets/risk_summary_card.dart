import 'package:flutter/material.dart';

class FactorItemData {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;

  const FactorItemData({
    required this.icon,
    required this.label,
    Color? backgroundColor,
    Color? iconColor,
    Color? color,
  }) : backgroundColor = backgroundColor ?? color ?? const Color(0xFFF1F5F9),
       iconColor = iconColor ?? const Color(0xFF1E293B);
}

class RiskSummaryCard extends StatelessWidget {
  final String title;
  final String level;
  final Color levelColor;
  final Color ringColor;
  final Color? accentColor;
  final String description;
  final String disclaimer;
  final List<FactorItemData> factors;
  final VoidCallback? onBackTap;
  final VoidCallback? onRecommendationTap;

  const RiskSummaryCard({
    super.key,
    required this.title,
    required this.level,
    required this.levelColor,
    required this.ringColor,
    this.accentColor,
    required this.description,
    required this.disclaimer,
    required this.factors,
    this.onBackTap,
    this.onRecommendationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Back button + Title
            Row(
              children: [
                GestureDetector(
                  onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 28,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),

            // Large Circular Risk Level Ring
            Center(
              child: Container(
                width: 224,
                height: 224,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: ringColor, width: 20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Tingkat Risiko',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: levelColor,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Risiko Burnout',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),

            // Description Paragraph (left-aligned)
            Text(
              description,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),

            // Medical Disclaimer Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: accentColor ?? const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.priority_high_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      disclaimer,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: Faktor yang Mempengaruhi
            const Text(
              'Faktor yang Mempengaruhi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 16),

            // Factor Items List
            ...factors.map(
              (factor) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: factor.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          factor.icon,
                          size: 20,
                          color: factor.iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        factor.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Button: Lihat Rekomendasi
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onRecommendationTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lihat Rekomendasi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
