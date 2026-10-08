import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
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
        Text(
          title,
          style: AppTextStyles.title.copyWith(
            fontSize: context.ui(
              AppTextStyles.title.fontSize ?? 32,
            ),
          ),
        ),
        SizedBox(height: context.ui(10)),
        Text(
          subtitle,
          style: AppTextStyles.subtitle.copyWith(
            fontSize: context.ui(
              AppTextStyles.subtitle.fontSize ?? 16,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({
    super.key,
    this.showLeaf = false,
  });

  final bool showLeaf;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -context.ui(40),
              left: context.ui(90),
              child: _blob(context.ui(160)),
            ),
            Positioned(
              top: context.ui(70),
              right: -context.ui(50),
              child: _blob(context.ui(120)),
            ),
            if (showLeaf)
              Positioned(
                bottom: context.ui(24),
                right: context.ui(28),
                child: CustomPaint(
                  size: Size(
                    context.ui(70),
                    context.ui(90),
                  ),
                  painter: _SproutPainter(),
                ),
              ),
            Positioned(
              bottom: -context.ui(40),
              left: context.ui(40),
              child: _blob(context.ui(140)),
            ),
          ],
        ),
      ),
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
    // Gambar memakai koordinat dasar 70 × 90.
    // Canvas mengikuti ukuran CustomPaint yang sudah diskalakan.
    canvas.save();
    canvas.scale(
      size.width / 70,
      size.height / 90,
    );

    const baseWidth = 70.0;
    const baseHeight = 90.0;

    final stem = Paint()
      ..color = const Color(0xFF8FD4C8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final leaf = Paint()
      ..color = const Color(0xFF8FD4C8).withValues(alpha: 0.85);

    final path = Path()
      ..moveTo(baseWidth * 0.45, baseHeight)
      ..quadraticBezierTo(
        baseWidth * 0.4,
        baseHeight * 0.5,
        baseWidth * 0.55,
        baseHeight * 0.12,
      );

    canvas.drawPath(path, stem);

    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(
          baseWidth * 0.28,
          baseHeight * 0.42,
        ),
        width: 28,
        height: 16,
      ),
      leaf,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(
          baseWidth * 0.72,
          baseHeight * 0.28,
        ),
        width: 26,
        height: 14,
      ),
      leaf,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SproutPainter oldDelegate) => false;
}