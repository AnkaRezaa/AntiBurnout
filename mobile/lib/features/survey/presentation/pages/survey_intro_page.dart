import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';

class SurveyIntroPage extends StatelessWidget {
  const SurveyIntroPage({super.key, this.onStartSurvey, this.onLater});

  final VoidCallback? onStartSurvey;
  final VoidCallback? onLater;

  static const _navy = Color(0xFF101D75);
  static const _muted = Color(0xFF7988B7);
  static const _purple = Color(0xFF5557FF);

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.factor(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -72 * scale,
              left: -64 * scale,
              child: Container(
                width: 152 * scale,
                height: 152 * scale,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F1FF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(context.ui(20)),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 520 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        tooltip: 'Kembali',
                        onPressed: onLater,
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: _navy,
                          size: context.ui(20),
                        ),
                      ),
                      SizedBox(height: context.ui(28)),
                      Text(
                        'Siap mengisi survei harian?',
                        style: TextStyle(
                          fontSize: context.ui(25),
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: _navy,
                        ),
                      ),
                      SizedBox(height: context.ui(12)),
                      Text(
                        'Jawab beberapa pertanyaan singkat untuk membantu kami memahami aktivitas, kebiasaan, dan kondisi harianmu.',
                        style: TextStyle(
                          fontSize: context.ui(14),
                          height: 1.45,
                          color: _muted,
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: context.ui(220),
                          height: context.ui(154),
                          child: const CustomPaint(
                            painter: _SurveyIllustration(),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(context.ui(15)),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFDFE5FF)),
                          borderRadius: BorderRadius.circular(context.ui(14)),
                        ),
                        child: Column(
                          children: [
                            _feature(
                              context,
                              Icons.description_outlined,
                              'Pertanyaan singkat',
                              'Mudah diisi dan tidak memakan banyak waktu.',
                            ),
                            SizedBox(height: context.ui(16)),
                            _feature(
                              context,
                              Icons.access_time_rounded,
                              'Hanya 3–5 menit',
                              'Survei singkat yang bisa kamu selesaikan dengan cepat.',
                            ),
                            SizedBox(height: context.ui(16)),
                            _feature(
                              context,
                              Icons.favorite_border_rounded,
                              'Bantu refleksi harian',
                              'Hasilnya membantu memantau pola aktivitas dan kesejahteraanmu.',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.ui(14)),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onLater,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _muted,
                                disabledForegroundColor: _muted,
                                side: const BorderSide(
                                  color: Color(0xFFC6D0FA),
                                ),
                                minimumSize: Size(0, context.ui(48)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    context.ui(12),
                                  ),
                                ),
                              ),
                              child: Text(
                                'Nanti saja',
                                style: TextStyle(
                                  fontSize: context.ui(14),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: context.ui(10)),
                          Expanded(
                            child: FilledButton(
                              onPressed: onStartSurvey,
                              style: FilledButton.styleFrom(
                                backgroundColor: _purple,
                                disabledBackgroundColor: _purple,
                                foregroundColor: Colors.white,
                                disabledForegroundColor: Colors.white,
                                minimumSize: Size(0, context.ui(48)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    context.ui(12),
                                  ),
                                ),
                              ),
                              child: Text(
                                'Mulai Survey',
                                style: TextStyle(
                                  fontSize: context.ui(14),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.ui(14)),
                      Container(
                        padding: EdgeInsets.all(context.ui(16)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F1FF),
                          borderRadius: BorderRadius.circular(context.ui(14)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: context.ui(48),
                              height: context.ui(48),
                              decoration: const BoxDecoration(
                                color: Color(0xFF5B8FFF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lightbulb_outline_rounded,
                                color: Colors.white,
                                size: context.ui(26),
                              ),
                            ),
                            SizedBox(width: context.ui(18)),
                            Expanded(
                              child: Text(
                                'Jawab dengan jujur agar hasil refleksi harian lebih akurat dan bermanfaat.',
                                style: TextStyle(
                                  fontSize: context.ui(12),
                                  height: 1.5,
                                  color: _muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feature(
    BuildContext context,
    IconData icon,
    String title,
    String body,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: context.ui(48),
          height: context.ui(48),
          decoration: const BoxDecoration(
            color: Color(0xFFE8F1FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _purple, size: context.ui(24)),
        ),
        SizedBox(width: context.ui(14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: context.ui(14),
                  fontWeight: FontWeight.w700,
                  color: _navy,
                ),
              ),
              SizedBox(height: context.ui(3)),
              Text(
                body,
                style: TextStyle(
                  fontSize: context.ui(12),
                  height: 1.4,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SurveyIllustration extends CustomPainter {
  const _SurveyIllustration();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 220, size.height / 154);
    final paint = Paint();
    paint.color = const Color(0xFFC5D0FF);
    canvas.save();
    canvas.translate(48, 106);
    canvas.rotate(-0.6);
    canvas.drawOval(const Rect.fromLTWH(-17, -54, 34, 78), paint);
    canvas.restore();
    paint.color = const Color(0xFFAEC3FF);
    canvas.save();
    canvas.translate(40, 124);
    canvas.rotate(-0.8);
    canvas.drawOval(const Rect.fromLTWH(-19, -37, 38, 62), paint);
    canvas.restore();
    paint.color = const Color(0xFFC5D0FF);
    canvas.save();
    canvas.translate(181, 124);
    canvas.rotate(0.7);
    canvas.drawOval(const Rect.fromLTWH(-20, -39, 40, 66), paint);
    canvas.restore();
    canvas.save();
    canvas.translate(66, 22);
    canvas.rotate(0.06);
    paint.color = const Color(0xFF8999FF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 105, 128),
        const Radius.circular(9),
      ),
      paint,
    );
    paint.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 7, 89, 113),
        const Radius.circular(3),
      ),
      paint,
    );
    paint.color = const Color(0xFF5557FF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(28, -6, 48, 20),
        const Radius.circular(5),
      ),
      paint,
    );
    canvas.drawCircle(const Offset(52, -8), 10, paint);
    paint.color = Colors.white;
    canvas.drawCircle(const Offset(52, -8), 4, paint);
    for (var i = 0; i < 3; i++) {
      final y = 36.0 + i * 30;
      paint.color = const Color(0xFF5557FF);
      canvas.drawCircle(Offset(25, y), 10, paint);
      paint
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(
        Path()
          ..moveTo(21, y)
          ..lineTo(25, y + 4)
          ..lineTo(31, y - 3),
        paint,
      );
      paint
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFD4DCFF);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(44, y - 5, 42, 5),
          const Radius.circular(3),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(44, y + 4, 29, 5),
          const Radius.circular(3),
        ),
        paint,
      );
    }
    canvas.restore();
    paint
      ..color = const Color(0xFF6065FF)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(188, 53), const Offset(198, 41), paint);
    canvas.drawLine(const Offset(198, 66), const Offset(211, 60), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SurveyIllustration oldDelegate) => false;
}
