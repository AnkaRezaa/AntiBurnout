import 'package:flutter/material.dart';

class LatestAssessmentCard extends StatelessWidget {
  final String riskLevel; // 'Rendah', 'Sedang', 'Tinggi'
  final String date;
  final VoidCallback? onDetailTap;

  const LatestAssessmentCard({
    super.key,
    this.riskLevel = 'Sedang',
    this.date = '18 September 2026',
    this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Label & Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HASIL ASESMEN TERAKHIR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Text(
                  riskLevel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          const Text(
            'Risiko Burnout',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),

          // Custom Risk Slider / Progress Bar
          _buildRiskBar(),
          const SizedBox(height: 8),

          // Labels Row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rendah',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
              Text(
                'Sedang',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D4ED8),
                ),
              ),
              Text(
                'Tinggi',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Footer Row: Date & Detail Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: onDetailTap,
                borderRadius: BorderRadius.circular(8),
                child: const Row(
                  children: [
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBar() {
    return SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gradient Bar Track
          Container(
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFD1FAE5), // Mint Green
                  Color(0xFFFEF08A), // Light Yellow
                  Color(0xFFFDE68A), // Amber
                  Color(0xFFFEE2E2), // Light Red/Pink
                ],
              ),
            ),
          ),

          // Faded Ticks (Left & Right)
          const Positioned(
            left: 12,
            child: CircleAvatar(radius: 4, backgroundColor: Color(0x40CBD5E1)),
          ),
          const Positioned(
            right: 12,
            child: CircleAvatar(radius: 4, backgroundColor: Color(0x40CBD5E1)),
          ),

          // Active Thumb Indicator (Center - Sedang)
          Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFDBEAFE),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
