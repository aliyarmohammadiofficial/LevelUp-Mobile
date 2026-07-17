import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Compact stat card with a circular progress indicator, label, and value
/// — matches the paired "Workout 4 of 6 completed" / "Calories 1,430/2,000
/// kcal" cards beneath the fasting timer on the reference Dashboard.
class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.valueLabel,
    required this.progress,
    required this.progressColor,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String valueLabel;
  final double progress;
  final Color progressColor;
  final String route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: AppRadius.lgRadius,
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgRadius,
          boxShadow: AppElevation.card(AppColors.ink900),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Icon(icon, size: 18, color: progressColor),
                ),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0, 1),
                    strokeWidth: 4,
                    backgroundColor: AppColors.chartTrackWeak,
                    valueColor: AlwaysStoppedAnimation(progressColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(label, style: theme.textTheme.bodySmall),
            const SizedBox(height: 2),
            Text(valueLabel, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
