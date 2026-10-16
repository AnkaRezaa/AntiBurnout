import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/assessment_colors.dart';
import '../../data/dashboard_motivations.dart';

class MotivationCard extends StatefulWidget {
  const MotivationCard({super.key, this.quote, this.now});

  /// An explicit quote remains fixed; otherwise the local date chooses it.
  final String? quote;

  /// Optional clock for deterministic date-change tests and previews.
  final DateTime Function()? now;

  @override
  State<MotivationCard> createState() => _MotivationCardState();
}

class _MotivationCardState extends State<MotivationCard>
    with WidgetsBindingObserver {
  Timer? _midnightTimer;

  DateTime _now() => (widget.now?.call() ?? DateTime.now()).toLocal();

  void _scheduleDailyRefresh() {
    _midnightTimer?.cancel();
    if (widget.quote != null) return;
    final now = _now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(tomorrow.difference(now), () {
      if (!mounted) return;
      setState(() {});
      _scheduleDailyRefresh();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleDailyRefresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active =
        TickerMode.valuesOf(context).enabled &&
        (ModalRoute.isCurrentOf(context) ?? true);
    // Re-check the date/timezone when returning to a retained tab or route.
    if (active) _scheduleDailyRefresh();
  }

  @override
  void didUpdateWidget(covariant MotivationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quote != widget.quote || oldWidget.now != widget.now) {
      _scheduleDailyRefresh();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.quote == null) {
      setState(() {});
      _scheduleDailyRefresh();
    }
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motivasi Hari Ini',
          style: AppTextStyles.title(context)
              .copyWith(fontSize: context.ui(17), fontWeight: FontWeight.w700),
        ),
        SizedBox(height: context.ui(AppSpacing.md)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.ui(18)),
          decoration: BoxDecoration(
            color: AssessmentColors.tint(
              context,
              AssessmentColors.motivationTint,
            ),
            borderRadius: BorderRadius.circular(context.ui(18)),
          ),
          child: Row(
            children: [
              Container(
                width: context.ui(48),
                height: context.ui(48),
                decoration: const BoxDecoration(
                  color: AssessmentColors.motivationIcon,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  size: context.ui(26),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: context.ui(AppSpacing.md)),
              Expanded(
                child: Text(
                  widget.quote ?? motivationForDate(_now()),
                  key: const ValueKey('dashboard-motivation-quote'),
                  style: AppTextStyles.subtitle(context)
                      .copyWith(fontSize: context.ui(12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
