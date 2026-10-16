import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/assessment_colors.dart';
import '../../../../shared/utils/date_formatter.dart';
import '../../../assessment/domain/entities/assessment.dart';
import '../models/weekly_risk_statistics.dart';

class WeeklyRiskChart extends StatefulWidget {
  const WeeklyRiskChart({super.key, required this.days});

  final List<DailyRiskAssessments> days;

  @override
  State<WeeklyRiskChart> createState() => _WeeklyRiskChartState();
}

class _WeeklyRiskChartState extends State<WeeklyRiskChart> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.days.isEmpty) return const SizedBox.shrink();
    final days = widget.days.reversed.toList(growable: false);
    final colors = AppColors.of(context);
    final textScale = math.max(
      1.0,
      MediaQuery.textScalerOf(context).scale(12) / 12,
    );
    final slotWidth = math.max(48.0, context.ui(48)) * textScale;
    final gap = context.ui(12);
    final minWidths = [
      for (final day in days)
        math.max(
          context.ui(88) * textScale,
          day.assessments.length * slotWidth + context.ui(16),
        ),
    ];
    final body = TextStyle(fontSize: context.ui(11), color: colors.body);
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth =
            minWidths.fold(0.0, (sum, width) => sum + width) +
            gap * (days.length - 1);
        final extra =
            math.max(0.0, constraints.maxWidth - totalWidth) / days.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (totalWidth > constraints.maxWidth) ...[
              Text('Geser untuk melihat tanggal lainnya.', style: body),
              SizedBox(height: context.ui(12)),
            ],
            Scrollbar(
              controller: _scrollController,
              thumbVisibility: totalWidth > constraints.maxWidth,
              child: SingleChildScrollView(
                key: const PageStorageKey('weekly-risk-chart-scroll'),
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(bottom: context.ui(16)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var index = 0; index < days.length; index++) ...[
                      if (index > 0) SizedBox(width: gap),
                      SizedBox(
                        key: ValueKey(
                          'risk-day-${days[index].date.toIso8601String()}',
                        ),
                        width: minWidths[index] + extra,
                        child: _DayGroup(
                          day: days[index],
                          slotWidth: slotWidth,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.day, required this.slotWidth});

  final DailyRiskAssessments day;
  final double slotWidth;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final body = TextStyle(fontSize: context.ui(11), color: colors.body);
    const weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${day.assessments.length} survei',
          textAlign: TextAlign.center,
          style: body.copyWith(color: colors.navy, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: context.ui(10)),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          child: Column(
            children: [
              SizedBox(
                height:
                    context.ui(100) +
                    context.ui(4) +
                    MediaQuery.textScalerOf(context).scale(context.ui(10)) *
                        1.4,
                child: day.assessments.isEmpty
                    ? Center(
                        child: Semantics(
                          label:
                              '${formatAssessmentDate(day.date)}, belum ada survei',
                          excludeSemantics: true,
                          child: Text(
                            '—',
                            style: body.copyWith(
                              fontSize: context.ui(22),
                              color: colors.hint,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final item in day.assessments.reversed)
                            _AssessmentBar(assessment: item, width: slotWidth),
                        ],
                      ),
              ),
              SizedBox(height: context.ui(8)),
            ],
          ),
        ),
        SizedBox(height: context.ui(8)),
        Text(
          weekdays[day.date.weekday - 1],
          textAlign: TextAlign.center,
          style: body,
        ),
        Text(
          '${day.date.day}/${day.date.month}',
          textAlign: TextAlign.center,
          style: body.copyWith(color: colors.navy, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _AssessmentBar extends StatelessWidget {
  const _AssessmentBar({required this.assessment, required this.width});

  final Assessment assessment;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final localTime = assessment.takenAt.toLocal();
    final time =
        '${localTime.hour.toString().padLeft(2, '0')}:'
        '${localTime.minute.toString().padLeft(2, '0')}';
    final color = switch (assessment.riskLevel) {
      RiskLevel.rendah => AssessmentColors.riskLow,
      RiskLevel.sedang => AssessmentColors.riskMedium,
      RiskLevel.tinggi => AssessmentColors.riskHigh,
    };
    return Tooltip(
      key: ValueKey('risk-survey-${assessment.id}'),
      message: '${assessment.riskLevel.label} · $time',
      triggerMode: TooltipTriggerMode.tap,
      child: Semantics(
        label:
            '${formatAssessmentDate(localTime, includeTime: true)}, '
            'risiko ${assessment.riskLevel.label}',
        excludeSemantics: true,
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: context.ui(18),
                    height: context.ui(switch (assessment.riskLevel) {
                      RiskLevel.rendah => 28,
                      RiskLevel.sedang => 54,
                      RiskLevel.tinggi => 80,
                    }),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(context.ui(6)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.ui(4)),
              Text(
                time,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: context.ui(10), color: colors.body),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
