import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/fasting_entities.dart';

/// Selectable plan tile used in the "Choose a Plan" sheet before starting
/// a fast — e.g. 16:8, 18:6, 20:4, OMAD.
class FastingPlanCard extends StatelessWidget {
  const FastingPlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final FastingPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgRadius,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.ink100,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.primarySurfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Text(
                plan.label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected ? Colors.white : AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.label, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    plan.description,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.ink500),
                  ),
                ],
              ),
            ),
            // `Radio.groupValue` / `Radio.onChanged` were deprecated after
            // Flutter 3.32 in favor of a `RadioGroup` ancestor. Each card
            // owns its selection state independently (driven by the
            // parent's `isSelected`/`onTap`), so it gets its own
            // single-radio `RadioGroup` rather than sharing one across
            // sibling cards.
            RadioGroup<bool>(
              groupValue: isSelected ? true : null,
              onChanged: (_) => onTap(),
              child: Radio<bool>(
                value: true,
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
