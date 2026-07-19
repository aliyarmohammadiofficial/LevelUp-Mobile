import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';
import '../../domain/entities/workout_routine.dart';

/// Matches the routine list rows on the reference Workout screen — "Push
/// Day / Chest • Shoulders • Triceps / 6 exercises" with a mascot icon and
/// chevron. The active/today routine (Push Day in the reference) renders as
/// the highlighted blue card; others render as plain surface cards.
class RoutineCard extends StatelessWidget {
  const RoutineCard({super.key, required this.routine, required this.onTap});

  final WorkoutRoutine routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighlighted = routine.isToday;

    final titleColor = isHighlighted ? Colors.white : AppColors.ink900;
    final subtitleColor = isHighlighted ? Colors.white.withValues(alpha: 0.85) : AppColors.ink500;
    final metaColor = isHighlighted ? Colors.white.withValues(alpha: 0.85) : AppColors.ink500;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: isHighlighted ? AppColors.primaryGradient : null,
          color: isHighlighted ? null : AppColors.surface,
          borderRadius: AppRadius.lgRadius,
          boxShadow: AppElevation.card(AppColors.ink900),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.name,
                    style: theme.textTheme.titleLarge?.copyWith(color: titleColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    routine.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: subtitleColor),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${routine.totalCount} exercises',
                    style: theme.textTheme.labelMedium?.copyWith(color: metaColor),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Colors.white.withValues(alpha: 0.18)
                    : AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Mascot(pose: MascotPose.wink, size: 30, animated: false),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right_rounded,
              color: isHighlighted ? Colors.white : AppColors.ink300,
            ),
          ],
        ),
      ),
    );
  }
}
