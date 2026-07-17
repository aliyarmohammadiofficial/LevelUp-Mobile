import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Pill-shaped segmented control for the four Progress sub-tabs, matching
/// the Overview/Calories/Macros style tab bar seen on the Nutrition and
/// Workout screens in the reference.
class ProgressTabBar extends StatelessWidget {
  const ProgressTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primarySurfaceAlt,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.standardCurve,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surface : Colors.transparent,
                  borderRadius: AppRadius.pillRadius,
                  boxShadow: isSelected ? AppElevation.card(AppColors.ink900) : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.ink500,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
