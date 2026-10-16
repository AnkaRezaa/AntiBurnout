import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/assessment_colors.dart';
import '../../../../shared/utils/date_formatter.dart';
import '../../../assessment/domain/entities/assessment.dart';

/// Categories are ordinal, not numerical prediction scores.
class RiskStatisticsCard extends StatelessWidget {
  const RiskStatisticsCard({super.key, required this.assessments});

  /// Newest first, shared with the latest assessment on the dashboard.
  final List<Assessment> assessments;

  Color _color(RiskLevel level) => switch (level) {
    RiskLevel.rendah => AssessmentColors.riskLow,
    RiskLevel.sedang => AssessmentColors.riskMedium,
    RiskLevel.tinggi => AssessmentColors.riskHigh,
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final recent = assessments.take(7).toList().reversed.toList();
    final body = TextStyle(fontSize: context.ui(12), color: colors.body);
    return Container(
      padding: EdgeInsets.all(context.ui(22)),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.ui(24)),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Statistik Risiko',
            style: TextStyle(
              fontSize: context.ui(20),
              fontWeight: FontWeight.w700,
              color: colors.navy,
            ),
          ),
          SizedBox(height: context.ui(6)),
          Text('Kenali perubahan kondisimu dari waktu ke waktu.', style: body),
          if (assessments.any((item) => item.isExample)) ...[
            SizedBox(height: context.ui(10)),
            Text(
              assessments.every((item) => item.isExample)
                  ? 'Pratinjau dengan data contoh'
                  : 'Termasuk data contoh',
              style: body.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          SizedBox(height: context.ui(20)),
          if (assessments.isEmpty)
            Text(
              'Statistik akan muncul setelah asesmen pertamamu.',
              style: body,
            )
          else ...[
            Text(
              '${assessments.length} asesmen tercatat',
              style: body.copyWith(
                color: colors.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.ui(12)),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked =
                    constraints.maxWidth < context.ui(240) ||
                    MediaQuery.textScalerOf(context).scale(12) > 18;
                return Wrap(
                  spacing: context.ui(8),
                  runSpacing: context.ui(8),
                  children: [
                    for (final level in RiskLevel.values)
                      Container(
                        width: stacked
                            ? constraints.maxWidth
                            : (constraints.maxWidth - context.ui(16)) / 3,
                        padding: EdgeInsets.all(context.ui(12)),
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            _color(level).withValues(alpha: .1),
                            colors.surface,
                          ),
                          borderRadius: BorderRadius.circular(context.ui(14)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: context.ui(8),
                              height: context.ui(8),
                              decoration: BoxDecoration(
                                color: _color(level),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(height: context.ui(6)),
                            Text(
                              '${assessments.where((a) => a.riskLevel == level).length}',
                              style: TextStyle(
                                fontSize: context.ui(24),
                                fontWeight: FontWeight.w700,
                                color: colors.navy,
                              ),
                            ),
                            Text(level.label, style: body),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: context.ui(24)),
            Text(
              '${recent.length} hasil terakhir',
              style: body.copyWith(
                color: colors.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.ui(12)),
            // Scroll horizontally at narrow widths / large text sizes.
            LayoutBuilder(
              builder: (context, constraints) {
                final textScale =
                    MediaQuery.textScalerOf(context).scale(12) / 12;
                final minWidth = context.ui(74) * textScale;
                final width = (constraints.maxWidth / recent.length).clamp(
                  minWidth,
                  double.infinity,
                );
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final item in recent)
                        Semantics(
                          label:
                              '${formatAssessmentDate(item.takenAt)}, risiko ${item.riskLevel.label}',
                          excludeSemantics: true,
                          child: SizedBox(
                            width: width,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.ui(4),
                              ),
                              child: Column(
                                children: [
                                  Text(item.riskLevel.label, style: body),
                                  SizedBox(height: context.ui(8)),
                                  SizedBox(
                                    height: context.ui(100),
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: context.ui(26),
                                        height: context.ui(
                                          switch (item.riskLevel) {
                                            RiskLevel.rendah => 32,
                                            RiskLevel.sedang => 64,
                                            RiskLevel.tinggi => 96,
                                          },
                                        ),
                                        decoration: BoxDecoration(
                                          color: _color(item.riskLevel),
                                          borderRadius: BorderRadius.circular(
                                            context.ui(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: context.ui(8)),
                                  Text(
                                    '${item.takenAt.day}/${item.takenAt.month}',
                                    style: body,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: context.ui(14)),
            Text(
              'Urutan dari lama ke baru. Tinggi batang menunjukkan kategori risiko, bukan skor medis.',
              style: body,
            ),
          ],
        ],
      ),
    );
  }
}
