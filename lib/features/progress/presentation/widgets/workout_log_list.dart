import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/progress_summary.dart';

/// The "Workouts" tab's log of this week's sessions — mirrors the rows
/// on the Workout History screen but scoped to the Progress feature's
/// own read-model.
class WorkoutLogList extends StatelessWidget {
  const WorkoutLogList({super.key, required this.entries});

  final List<WorkoutLogEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppElevation.card(AppColors.ink900),
      ),
      child: Column(
        children: [
          for (int i = 0; i < entries.length; i++) ...[
            _WorkoutRow(entry: entries[i]),
            if (i != entries.length - 1)
              const Divider(height: 1, color: AppColors.ink100, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  const _WorkoutRow({required this.entry});
  final WorkoutLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isRestDay = !entry.completed && entry.durationMinutes == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isRestDay ? AppColors.ink100 : AppColors.primarySurfaceAlt,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isRestDay ? Icons.bedtime_rounded : Icons.fitness_center_rounded,
              size: 18,
              color: isRestDay ? AppColors.ink500 : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.label, style: textTheme.titleMedium),
                Text(DateFormat.MMMd().format(entry.date), style: textTheme.bodySmall),
              ],
            ),
          ),
          if (!isRestDay)
            Text('${entry.durationMinutes} min', style: textTheme.titleSmall)
          else
            Text('Rest', style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
