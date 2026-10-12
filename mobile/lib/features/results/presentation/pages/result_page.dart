import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../widgets/risk_summary_card.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RiskSummaryCard(
          title: 'Hasil Prediksi',
          level: 'Sedang',
          levelColor: const Color(0xFFF59200),
          ringColor: const Color(0xFFF59200),
          accentColor: const Color(0xFFFFFBEB),
          description:
              'Berdasarkan jawaban yang kamu berikan, terdapat indikasi risiko burnout pada tingkat sedang.',
          disclaimer:
              'Ini bukan diagnosis medis, tetapi indikasi awal yang dapat membantumu lebih memahami kondisi diri.',
          factors: const [
            FactorItemData(
              icon: Icons.nightlight_outlined,
              label: 'Durasi tidur kurang stabil',
              backgroundColor: Color(0xFFE0E7FF),
              iconColor: Color(0xFF4F46E5),
            ),
            FactorItemData(
              icon: Icons.view_column_outlined,
              label: 'Beban aktivitas cukup tinggi',
              backgroundColor: Color(0xFFD1FAE5),
              iconColor: Color(0xFF10B981),
            ),
            FactorItemData(
              icon: Icons.favorite_rounded,
              label: 'Tingkat stres yang meningkat',
              backgroundColor: Color(0xFFFFE4E6),
              iconColor: Color(0xFFF43F5E),
            ),
          ],
          onBackTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(RoutePaths.home);
            }
          },
          onRecommendationTap: () {
            context.go(RoutePaths.recommendation);
          },
        ),
      ),
    );
  }
}
