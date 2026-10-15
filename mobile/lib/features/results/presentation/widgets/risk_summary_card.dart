import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/assessment_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_page_header.dart';

class FactorItemData {
  const FactorItemData({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
}

class AnswerSummaryItemData {
  const AnswerSummaryItemData({required this.label, required this.value});

  final String label;
  final String value;
}

class RiskSummaryCard extends StatelessWidget {
  const RiskSummaryCard({
    super.key,
    this.scrollKey,
    required this.title,
    required this.level,
    required this.levelColor,
    required this.ringColor,
    required this.description,
    required this.assessmentDate,
    required this.disclaimer,
    required this.factors,
    required this.answerSummary,
    this.isExample = false,
    this.onBackTap,
    this.onRecommendationTap,
  });

  final Key? scrollKey;
  final String title;
  final String level;
  final Color levelColor;
  final Color ringColor;
  final String description;
  final String assessmentDate;
  final String disclaimer;
  final List<FactorItemData> factors;
  final List<AnswerSummaryItemData> answerSummary;
  final bool isExample;
  final VoidCallback? onBackTap;
  final VoidCallback? onRecommendationTap;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = AppTextStyles.subtitle(context)
        .copyWith(fontSize: context.ui(14));
    final sectionStyle = AppTextStyles.title(context)
        .copyWith(fontSize: context.ui(18), fontWeight: FontWeight.w700);

    return SingleChildScrollView(
      key: scrollKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResultHeader(title: title, onBack: onBackTap),
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.ui(AppSpacing.lg),
              0,
              context.ui(AppSpacing.lg),
              context.ui(AppSpacing.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.ui(AppSpacing.md)),
                _RiskRing(
                  level: level,
                  color: levelColor,
                  ringColor: ringColor,
                  bodyStyle: bodyStyle,
                ),
                SizedBox(height: context.ui(AppSpacing.md)),
                Text(description, style: bodyStyle),
                SizedBox(height: context.ui(AppSpacing.xs)),
                Wrap(
                  spacing: context.ui(AppSpacing.sm),
                  runSpacing: context.ui(AppSpacing.sm),
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Asesmen $assessmentDate',
                      style: bodyStyle.copyWith(fontSize: context.ui(12)),
                    ),
                    if (isExample)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.ui(AppSpacing.sm),
                          vertical: context.ui(AppSpacing.xs),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.of(context).blob,
                          borderRadius: BorderRadius.circular(context.ui(20)),
                        ),
                        child: Text(
                          'Data contoh',
                          style: bodyStyle.copyWith(
                            fontSize: context.ui(11),
                            fontWeight: FontWeight.w600,
                            color: AppColors.of(context).primaryDark,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: context.ui(AppSpacing.md)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.ui(AppSpacing.md)),
                  decoration: BoxDecoration(
                    color: AssessmentColors.tint(
                      context,
                      AssessmentColors.disclaimerTint,
                    ),
                    borderRadius: BorderRadius.circular(
                      context.ui(AppSpacing.radius),
                    ),
                    border: Border.all(
                      color: AssessmentColors.disclaimerBorder,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_rounded,
                        color: AssessmentColors.disclaimerIcon,
                        size: context.ui(28),
                      ),
                      SizedBox(width: context.ui(AppSpacing.sm)),
                      Expanded(
                        child: Text(
                          disclaimer,
                          style: bodyStyle.copyWith(fontSize: context.ui(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.ui(AppSpacing.lg)),
                Text('Faktor yang Mempengaruhi', style: sectionStyle),
                SizedBox(height: context.ui(AppSpacing.sm)),
                if (factors.isEmpty)
                  Text(
                    'Faktor dari model belum tersedia untuk asesmen ini.',
                    style: bodyStyle,
                  )
                else ...[
                  Text(
                    isExample ? 'Faktor pada contoh hasil asesmen ini.' : 'Faktor yang disertakan dalam hasil model untuk asesmen ini.',
                    style: bodyStyle.copyWith(fontSize: context.ui(12)),
                  ),
                  SizedBox(height: context.ui(AppSpacing.sm)),
                  for (final factor in factors)
                    Padding(
                      padding: EdgeInsets.only(bottom: context.ui(10)),
                      child: Row(
                        children: [
                          Container(
                            width: context.ui(38),
                            height: context.ui(38),
                            decoration: BoxDecoration(
                              color: AssessmentColors.tint(
                                context,
                                factor.backgroundColor,
                              ),
                              borderRadius: BorderRadius.circular(
                                context.ui(12),
                              ),
                            ),
                            child: Icon(
                              factor.icon,
                              size: context.ui(20),
                              color: factor.iconColor,
                            ),
                          ),
                          SizedBox(width: context.ui(12)),
                          Expanded(child: Text(factor.label, style: bodyStyle)),
                        ],
                      ),
                    ),
                ],
                SizedBox(height: context.ui(AppSpacing.lg)),
                Text('Ringkasan Jawaban', style: sectionStyle),
                SizedBox(height: context.ui(AppSpacing.sm)),
                Text(
                  isExample ? 'Ringkasan jawaban pada contoh asesmen ini.' : 'Ringkasan jawaban survei, bukan kontribusi model prediksi.',
                  style: bodyStyle.copyWith(fontSize: context.ui(12)),
                ),
                SizedBox(height: context.ui(AppSpacing.sm)),
                if (answerSummary.isEmpty)
                  Text('Ringkasan jawaban belum tersedia.', style: bodyStyle)
                else
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.ui(AppSpacing.md)),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.of(context).border),
                      borderRadius: BorderRadius.circular(
                        context.ui(AppSpacing.radius),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < answerSummary.length; i++) ...[
                          if (i > 0)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: context.ui(AppSpacing.sm),
                              ),
                              child: Divider(
                                height: 1,
                                color: AppColors.of(context).border,
                              ),
                            ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${answerSummary[i].label}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: answerSummary[i].value),
                              ],
                            ),
                            style: bodyStyle,
                          ),
                        ],
                      ],
                    ),
                  ),
                SizedBox(height: context.ui(AppSpacing.lg)),
                AppButton(
                  label: 'Lihat Rekomendasi',
                  onPressed: onRecommendationTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskRing extends StatelessWidget {
  const _RiskRing({
    required this.level,
    required this.color,
    required this.ringColor,
    required this.bodyStyle,
  });

  final String level;
  final Color color;
  final Color ringColor;
  final TextStyle bodyStyle;

  @override
  Widget build(BuildContext context) {
    final levelStyle = AppTextStyles.title(context).copyWith(
      fontSize: context.ui(32),
      fontWeight: FontWeight.w700,
      color: color,
    );
    final borderWidth = context.ui(18);
    final contentPadding = context.ui(AppSpacing.sm);
    final gap = context.ui(AppSpacing.xs);

    Size measure(
      String text,
      TextStyle style, {
      double maxWidth = double.infinity,
    }) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: DefaultTextStyle.of(context).style.merge(style),
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: maxWidth);
      final size = painter.size;
      painter.dispose();
      return size;
    }

    Widget ring(double diameter, Widget child) => Container(
      width: diameter,
      height: diameter,
      padding: EdgeInsets.all(contentPadding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: borderWidth),
      ),
      child: Center(child: child),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final top = measure('Tingkat Risiko', bodyStyle);
        final risk = measure(level, levelStyle);
        final bottom = measure('Risiko Burnout', bodyStyle);
        final contentWidth = math.max(
          top.width,
          math.max(risk.width, bottom.width),
        );
        final contentHeight =
            top.height + risk.height + bottom.height + gap * 2;
        // A rectangle fits inside a circle when its diagonal fits the diameter.
        // Include both the decoration border and its additional content padding.
        final inset = 2 * (borderWidth + contentPadding);
        final requiredDiameter =
            math.sqrt(
              contentWidth * contentWidth + contentHeight * contentHeight,
            ) +
            inset +
            2;

        final Widget content;
        if (requiredDiameter <= constraints.maxWidth) {
          content = ring(
            math
                .max(context.ui(220), requiredDiameter)
                .clamp(0.0, constraints.maxWidth)
                .toDouble(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tingkat Risiko',
                  style: bodyStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: gap),
                Text(level, style: levelStyle, textAlign: TextAlign.center),
                SizedBox(height: gap),
                Text(
                  'Risiko Burnout',
                  style: bodyStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else {
          // Enlarged text can move the captions outside the ring. Preserve the
          // user's font size and allow the risk label to wrap when necessary.
          final innerSquare = math.max(
            1.0,
            (constraints.maxWidth - inset - 2) / math.sqrt2,
          );
          final wrappedRisk = measure(level, levelStyle, maxWidth: innerSquare);
          final riskFits = wrappedRisk.height <= innerSquare;
          final riskDiameter =
              math.sqrt(
                wrappedRisk.width * wrappedRisk.width +
                    wrappedRisk.height * wrappedRisk.height,
              ) +
              inset +
              2;
          content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tingkat Risiko',
                style: bodyStyle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: gap),
              ring(
                riskFits
                    ? math
                          .max(context.ui(220), riskDiameter)
                          .clamp(0.0, constraints.maxWidth)
                          .toDouble()
                    : math.min(context.ui(180), constraints.maxWidth),
                riskFits
                    ? SizedBox(
                        width: innerSquare,
                        child: Text(
                          level,
                          style: levelStyle,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Icon(
                        Icons.favorite_outline_rounded,
                        size: context.ui(48),
                        color: color,
                      ),
              ),
              if (!riskFits) ...[
                SizedBox(height: gap),
                Text(level, style: levelStyle, textAlign: TextAlign.center),
              ],
              SizedBox(height: gap),
              Text(
                'Risiko Burnout',
                style: bodyStyle,
                textAlign: TextAlign.center,
              ),
            ],
          );
        }

        return Center(
          child: Semantics(
            label: 'Tingkat risiko burnout: $level',
            excludeSemantics: true,
            child: content,
          ),
        );
      },
    );
  }
}

class ResultHeader extends StatelessWidget {
  const ResultHeader({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      title: title,
      onBack: onBack ?? () => Navigator.of(context).maybePop(),
      fontSize: 22,
    );
  }
}
