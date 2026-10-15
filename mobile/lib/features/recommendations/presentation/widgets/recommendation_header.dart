import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_page_header.dart';

class RecommendationHeader extends StatelessWidget {
  const RecommendationHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      title: 'Rekomendasi untuk Kamu',
      onBack: onBack,
      tooltip: 'Kembali ke hasil',
      fontSize: 20,
    );
  }
}
