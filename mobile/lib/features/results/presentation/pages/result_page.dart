import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../widgets/risk_summary_card.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: SafeArea(
        child: Center(
          child: RiskSummaryCard(
            title: 'Hasil Prediksi',
            level: 'Sedang',
            levelColor: const Color(0xFFF59E0B),
            ringColor: const Color(0xFFFBBF24),
            accentColor: const Color(0xFFFFF1C7),
            description:
                'Berdasarkan jawaban yang kamu berikan, terdapat indikasi risiko burnout pada tingkat sedang.',
            disclaimer:
                'Ini bukan diagnosis medis, tetapi indikasi awal yang dapat membantu kamu memahami kondisi diri.',
            factors: const [
              FactorItemData(
                icon: Icons.nightlight_outlined,
                label: 'Durasi tidur kurang stabil',
                color: Color(0xFFBFDBFE),
              ),
              FactorItemData(
                icon: Icons.view_column_outlined,
                label: 'Beban aktivitas cukup tinggi',
                color: Color(0xFFC7D2FE),
              ),
              FactorItemData(
                icon: Icons.favorite_rounded,
                label: 'Tingkat stres yang meningkat',
                color: Color(0xFFFBCFE8),
              ),
            ],
            onRecommendationTap: () {
              context.go(RoutePaths.recommendation);
            },
          ),
        ),
      ),
    );
  }
}
