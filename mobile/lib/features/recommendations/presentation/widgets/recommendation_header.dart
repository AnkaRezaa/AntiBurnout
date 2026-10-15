import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_back_button.dart';

class RecommendationHeader extends StatelessWidget {
  const RecommendationHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppBackButton(onPressed: onBack, tooltip: 'Kembali ke hasil'),
        SizedBox(width: context.ui(AppSpacing.xs)),
        Expanded(
          child: Text(
            'Rekomendasi untuk Kamu',
            style: AppTextStyles.title(
              context,
            ).copyWith(fontSize: context.ui(20), fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
