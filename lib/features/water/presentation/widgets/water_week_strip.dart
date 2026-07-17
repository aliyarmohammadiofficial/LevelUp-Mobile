import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/water_entities.dart';

/// Compact 7-day hydration strip — one bar per day, filled proportional to
/// that day's cups vs goal. Matches the weekly-glance pattern used on the
/// Progress screen's chart.
class WaterWeekStrip extends StatelessWidget {
  const WaterWeekStrip({super.key, required this.entries});

  final List<WaterHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppElevation.card(AppColors.ink900),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Week', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: entries.map((entry) {
              final progress = entry.cupGoal == 0
                  ? 0.0
                  : (entry.cupsLogged / entry.cupGoal).clamp(0, 1).toDouble();
              return Column(
                children: [
                  SizedBox(
                    height: 64,
                    width: 18,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: progress == 0 ? 0.04 : progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: entry.goalMet ? AppColors.primary : AppColors.primaryFaint,
                            borderRadius: AppRadius.pillRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    DateFormat('E').format(entry.date).substring(0, 1),
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.ink500),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
