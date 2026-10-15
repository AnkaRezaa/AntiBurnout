import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_page_header.dart';

class SurveyIntroPage extends StatelessWidget {
  const SurveyIntroPage({super.key, this.onStartSurvey, this.onLater});

  final VoidCallback? onStartSurvey;
  final VoidCallback? onLater;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppPageHeader(
                title: 'Survei Harian',
                showBackButton: false,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.ui(24),
                  context.ui(12),
                  context.ui(24),
                  context.ui(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.ui(20)),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.of(context).blob,
                            AppColors.of(context).primary
                                .withValues(alpha: 0.04),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(context.ui(24)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.ui(12),
                              vertical: context.ui(8),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.of(context).surface,
                              borderRadius: BorderRadius.circular(
                                context.ui(24),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: context.ui(16),
                                  color: AppColors.of(context).primary,
                                ),
                                SizedBox(width: context.ui(6)),
                                Flexible(
                                  child: Text(
                                    'Waktu untuk dirimu · 3–5 menit',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.link(context)
                                        .copyWith(fontSize: context.ui(12)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: context.ui(8)),
                          SizedBox(
                            width: context.ui(186),
                            height: context.ui(130),
                            child: const CustomPaint(
                              painter: _SurveyIllustration(),
                            ),
                          ),
                          SizedBox(height: context.ui(8)),
                          Text(
                            'Bagaimana harimu?',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.title(context)
                                .copyWith(fontSize: context.ui(23)),
                          ),
                          SizedBox(height: context.ui(4)),
                          Text(
                            'Luangkan waktu sejenak untuk mengenali aktivitas, '
                            'kebiasaan, dan perasaanmu hari ini.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.subtitle(context)
                                .copyWith(fontSize: context.ui(12)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.ui(18)),
                    Text(
                      'Langkah kecil, manfaat berarti',
                      style: AppTextStyles.title(context).copyWith(
                        fontSize: context.ui(17),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: context.ui(6)),
                    Container(
                      padding: EdgeInsets.all(context.ui(16)),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).surface,
                        border: Border.all(color: AppColors.of(context).border),
                        borderRadius: BorderRadius.circular(
                          context.ui(AppSpacing.radius),
                        ),
                      ),
                      child: Column(
                        children: [
                          _feature(
                            context,
                            Icons.assignment_outlined,
                            'Pertanyaan sederhana',
                            'Ceritakan aktivitas dan kebiasaan harianmu.',
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: context.ui(12),
                            ),
                            child: Divider(
                              height: 1,
                              color: AppColors.of(context).border,
                            ),
                          ),
                          _feature(
                            context,
                            Icons.favorite_border_rounded,
                            'Kenali pola keseharianmu',
                            'Bantu refleksi dan pantau kesejahteraanmu.',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.ui(16)),
                    Container(
                      padding: EdgeInsets.all(context.ui(14)),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).leaf
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          context.ui(AppSpacing.fieldRadius),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: AppColors.of(context).navy,
                            size: context.ui(18),
                          ),
                          SizedBox(width: context.ui(10)),
                          Expanded(
                            child: Text(
                              'Tidak ada jawaban benar atau salah. '
                              'Jawab sesuai kondisi yang kamu rasakan.',
                              style: AppTextStyles.subtitle(context)
                                  .copyWith(fontSize: context.ui(11)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.ui(24)),
                    AppButton(label: 'Mulai Survei', onPressed: onStartSurvey),
                  ],
                ),
              ),
            ],
          ),
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
          width: context.ui(44),
          height: context.ui(44),
          decoration: BoxDecoration(
            color: AppColors.of(context).blob.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(context.ui(10)),
          ),
          child: Icon(
            icon,
            color: AppColors.of(context).primary,
            size: context.ui(22),
          ),
        ),
        SizedBox(width: context.ui(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.subtitle(context).copyWith(
                  fontSize: context.ui(14),
                  fontWeight: FontWeight.w700,
                  color: AppColors.of(context).navy,
                ),
              ),
              SizedBox(height: context.ui(2)),
              Text(
                body,
                style: AppTextStyles.subtitle(context)
                    .copyWith(fontSize: context.ui(12)),
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
    paint.color = AppColors.blob;
    canvas.save();
    canvas.translate(48, 106);
    canvas.rotate(-0.6);
    canvas.drawOval(const Rect.fromLTWH(-17, -54, 34, 78), paint);
    canvas.restore();
    paint.color = AppColors.leaf.withValues(alpha: 0.5);
    canvas.save();
    canvas.translate(40, 124);
    canvas.rotate(-0.8);
    canvas.drawOval(const Rect.fromLTWH(-19, -37, 38, 62), paint);
    canvas.restore();
    paint.color = AppColors.blob;
    canvas.save();
    canvas.translate(181, 124);
    canvas.rotate(0.7);
    canvas.drawOval(const Rect.fromLTWH(-20, -39, 40, 66), paint);
    canvas.restore();
    canvas.save();
    canvas.translate(66, 22);
    canvas.rotate(0.06);
    paint.color = AppColors.primary.withValues(alpha: 0.5);
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
    paint.color = AppColors.primary;
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
      paint.color = AppColors.primary;
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
        ..color = AppColors.blob;
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
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(188, 53), const Offset(198, 41), paint);
    canvas.drawLine(const Offset(198, 66), const Offset(211, 60), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SurveyIllustration oldDelegate) => false;
}
