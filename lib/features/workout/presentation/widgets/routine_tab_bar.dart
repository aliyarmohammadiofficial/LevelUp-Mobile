import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Matches the "Routines / Exercises / History" segmented tabs at the top
/// of the reference Workout screen.
class RoutineTabBar extends StatelessWidget {
  const RoutineTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: List.generate(tabs.length, (index) {
        final isSelected = index == selectedIndex;
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          child: InkWell(
            onTap: () => onSelected(index),
            borderRadius: AppRadius.smRadius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tabs[index],
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.ink500,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: AppMotion.fast,
                  height: 3,
                  width: isSelected ? 22 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.pillRadius,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
