import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/workout_routine.dart';

/// Numbered exercise row matching the reference Workout Detail screen:
/// "1  Bench Press  4 sets • 8-12 reps  >".
class ExerciseListTile extends StatelessWidget {
  const ExerciseListTile({
    super.key,
    required this.index,
    required this.exercise,
    required this.onTap,
  });

  final int index;
  final WorkoutExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgRadius,
          boxShadow: AppElevation.card(AppColors.ink900),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: exercise.isCompleted ? AppColors.successSurface : AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: exercise.isCompleted
                  ? const Icon(Icons.check_rounded, size: 18, color: AppColors.success)
                  : Text(
                      '$index',
                      style: theme.textTheme.titleSmall?.copyWith(color: AppColors.primary),
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${exercise.targetSets} sets • ${exercise.repRangeLabel}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.ink300),
          ],
        ),
      ),
    );
  }
}
