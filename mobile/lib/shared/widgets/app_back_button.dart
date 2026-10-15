import 'package:flutter/material.dart';

import '../../core/responsive/app_scale.dart';
import '../../core/theme/app_colors.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Kembali',
  });

  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: AppColors.of(context).navy,
        backgroundColor: Colors.transparent,
        minimumSize: const Size(48, 48),
      ),
      icon: Icon(Icons.chevron_left_rounded, size: context.ui(28)),
    );
  }
}
