import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/fasting_entities.dart';

class FastingHistoryTile extends StatelessWidget {
  const FastingHistoryTile({super.key, required this.entry});

  final FastingHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = entry.goalMet ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdRadius,
        boxShadow: AppElevation.card(AppColors.ink900),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: entry.goalMet ? AppColors.successSurface : AppColors.warningSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              entry.goalMet ? Icons.check_rounded : Icons.close_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('EEE, MMM d').format(entry.date), style: theme.textTheme.titleMedium),
                Text(
                  '${entry.planLabel} plan',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.ink500),
                ),
              ],
            ),
          ),
          Text(
            '${entry.achievedHours.toStringAsFixed(1)}h',
            style: theme.textTheme.titleMedium?.copyWith(color: statusColor),
          ),
        ],
      ),
    );
  }
}
