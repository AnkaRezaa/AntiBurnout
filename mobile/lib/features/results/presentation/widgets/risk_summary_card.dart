import 'package:flutter/material.dart';

class FactorItemData {
  final IconData icon;
  final String label;
  final Color color;

  const FactorItemData({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class RiskSummaryCard extends StatelessWidget {
  final String title;
  final String level;
  final Color levelColor;
  final Color ringColor;
  final Color accentColor;
  final String description;
  final String disclaimer;
  final List<FactorItemData> factors;
  final VoidCallback? onRecommendationTap;

  const RiskSummaryCard({
    super.key,
    required this.title,
    required this.level,
    required this.levelColor,
    required this.ringColor,
    required this.accentColor,
    required this.description,
    required this.disclaimer,
    required this.factors,
    this.onRecommendationTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.chevron_left_rounded,
                size: 26,
                color: Color(0xFF1E293B),
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: Container(
              width: 212,
              height: 212,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ringColor,
                  width: 12,
                ),
                color: Colors.white,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tingkat Risiko',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ringColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: levelColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Risiko Burnout',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: levelColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 23,
                  height: 23,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.priority_high_rounded,
                    size: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    disclaimer,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF334155),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Faktor yang Mempengaruhi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          ...factors.map(
            (factor) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: factor.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      factor.icon,
                      size: 16,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      factor.label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRecommendationTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D5AF1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Lihat Rekomendasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
