import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/responsive/app_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/history_state.dart';

class HistoryFilterBar extends StatelessWidget {
  final HistoryFilter selected;
  final ValueChanged<HistoryFilter> onSelected;

  const HistoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const filters = HistoryFilter.values;
    final fontSize = context.ui(12);
    final verticalPadding = context.ui(AppSpacing.sm);
    final visualHeight = math.max(
      context.ui(36),
      MediaQuery.textScalerOf(context).scale(fontSize) * 1.2 +
          verticalPadding * 2,
    );

    return SizedBox(
      height: math.max(48.0, visualHeight).ceilToDouble(),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => SizedBox(width: context.ui(10)),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selected;

          return Semantics(
            selected: isSelected,
            child: Align(
              widthFactor: 1,
              child: TextButton(
                onPressed: () => onSelected(filter),
                style: TextButton.styleFrom(
                  backgroundColor: isSelected
                      ? AppColors.of(context).primary
                      : AppColors.of(context).blob,
                  foregroundColor: isSelected
                      ? AppColors.of(context).onPrimary
                      : AppColors.of(context).body,
                  minimumSize: Size(0, context.ui(36)),
                  tapTargetSize: MaterialTapTargetSize.padded,
                  visualDensity: VisualDensity.standard,
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.ui(18),
                    vertical: verticalPadding,
                  ),
                  alignment: Alignment.center,
                  textStyle: AppTextStyles.subtitle(context).copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                child: Text(filter.label),
              ),
            ),
          );
        },
      ),
    );
  }
}
