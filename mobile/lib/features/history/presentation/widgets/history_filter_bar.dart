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

    return SizedBox(
      height:
          (MediaQuery.textScalerOf(context).scale(context.ui(12)) * 1.5 +
                  context.ui(AppSpacing.md))
              .clamp(48.0, double.infinity),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selected;

          return Material(
            color: isSelected
                ? AppColors.of(context).primary
                : AppColors.of(context).blob,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onSelected(filter),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                child: Text(
                  filter.label,
                  style: AppTextStyles.subtitle(context).copyWith(
                    fontSize: context.ui(12),
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.of(context).onPrimary
                        : AppColors.of(context).body,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
