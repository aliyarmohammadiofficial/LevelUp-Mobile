import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Rounded, tappable choice card with an icon, title, optional subtitle,
/// and a selected state (filled border + tint + check). Used for goal,
/// sex, and activity-level selection screens so those three steps share
/// one visual language.
class OnboardingOptionCard extends StatelessWidget {
  const OnboardingOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standardCurve,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primarySurface : AppColors.surface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.ink100,
          width: isSelected ? 2 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.lgRadius,
        child: InkWell(
          borderRadius: AppRadius.lgRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.primarySurface,
                    borderRadius: AppRadius.smRadius,
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      if (subtitle != null)
                        Text(subtitle!, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  duration: AppMotion.fast,
                  opacity: isSelected ? 1 : 0,
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
