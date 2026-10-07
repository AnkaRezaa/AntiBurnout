import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.title),
        const SizedBox(height: 10),
        Text(subtitle, style: AppTextStyles.subtitle),
      ],
    );
  }
}

class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({super.key, this.showLeaf = false});

  final bool showLeaf;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -40,
          left: 90,
          child: _blob(160),
        ),
        Positioned(
          top: 70,
          right: -50,
          child: _blob(120),
        ),
        if (showLeaf)
          Positioned(
            bottom: 24,
            right: 28,
            child: CustomPaint(
              size: const Size(70, 90),
              painter: _SproutPainter(),
            ),
          ),
        Positioned(
          bottom: -40,
          left: 40,
          child: _blob(140),
        ),
      ],
    );
  }

  Widget _blob(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.blob,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stem = Paint()
      ..color = const Color(0xFF8FD4C8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final leaf = Paint()..color = const Color(0xFF8FD4C8).withValues(alpha: 0.85);

    final path = Path()
      ..moveTo(size.width * 0.45, size.height)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.5,
        size.width * 0.55,
        size.height * 0.12,
      );
    canvas.drawPath(path, stem);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.28, size.height * 0.42),
        width: 28,
        height: 16,
      ),
      leaf,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.72, size.height * 0.28),
        width: 26,
        height: 14,
      ),
      leaf,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
