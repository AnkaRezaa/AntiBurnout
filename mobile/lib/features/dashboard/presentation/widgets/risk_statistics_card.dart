import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/assessment_colors.dart';
import '../../../../shared/utils/date_formatter.dart';
import '../../../assessment/domain/entities/assessment.dart';
import '../models/weekly_risk_statistics.dart';
import 'weekly_risk_chart.dart';

/// Categories are ordinal, not numerical prediction scores.
class RiskStatisticsCard extends StatefulWidget {
  const RiskStatisticsCard({super.key, required this.assessments, this.now});

  final List<Assessment> assessments;

  /// A fixed clock for previews and tests; otherwise the period follows today.
  final DateTime? now;

  @override
  State<RiskStatisticsCard> createState() => _RiskStatisticsCardState();
}

class _RiskStatisticsCardState extends State<RiskStatisticsCard>
    with WidgetsBindingObserver {
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnightRefresh();
  }

  @override
  void didUpdateWidget(covariant RiskStatisticsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.now != widget.now) _scheduleMidnightRefresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.now == null) {
      setState(() {});
      _scheduleMidnightRefresh();
    }
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    if (widget.now != null) return;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(tomorrow.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _scheduleMidnightRefresh();
    });
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Color _color(RiskLevel level) => switch (level) {
    RiskLevel.rendah => AssessmentColors.riskLow,
    RiskLevel.sedang => AssessmentColors.riskMedium,
    RiskLevel.tinggi => AssessmentColors.riskHigh,
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final week = WeeklyRiskStatistics.fromAssessments(
      widget.assessments,
      now: widget.now ?? DateTime.now(),
    );
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
          Text('Ringkasan seluruh riwayat survei', style: body),
          if (widget.assessments.any((item) => item.isExample)) ...[
            SizedBox(height: context.ui(10)),
            Text(
              widget.assessments.every((item) => item.isExample)
                  ? 'Pratinjau dengan data contoh'
                  : 'Termasuk data contoh',
              style: body.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          SizedBox(height: context.ui(20)),
          Text(
            '${widget.assessments.length} asesmen secara keseluruhan',
            key: const ValueKey('risk-total-count'),
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
                            '${widget.assessments.where((item) => item.riskLevel == level).length}',
                            key: ValueKey('risk-total-${level.name}'),
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
          Divider(height: 1, color: colors.border),
          SizedBox(height: context.ui(20)),
          Text(
            'Grafik 7 hari terakhir',
            style: body.copyWith(
              color: colors.navy,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.ui(6)),
          Text(
            '${formatAssessmentDate(week.days.first.date)} – ${formatAssessmentDate(week.days.last.date)}',
            style: body,
          ),
          SizedBox(height: context.ui(6)),
          // Text(
          //   '${week.assessments.length} asesmen dalam 7 hari terakhir',
          //   style: body,
          // ),
          // SizedBox(height: context.ui(6)),
          Text(
            week.assessments.isEmpty
                ? 'Belum ada survei dalam 7 hari terakhir.'
                : 'Setiap batang mewakili satu survei. Ketuk untuk melihat risikonya.',
            style: body,
          ),
          SizedBox(height: context.ui(12)),
          WeeklyRiskChart(days: week.days),
          SizedBox(height: context.ui(14)),
          Text(
            'Urutan dari baru ke lama. Tinggi batang menunjukkan kategori risiko, bukan skor medis.',
            style: body,
          ),
        ],
      ),
    );
  }
}
