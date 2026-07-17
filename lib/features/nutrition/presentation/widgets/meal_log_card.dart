import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/nutrition_entities.dart';

/// One meal-slot card ("Breakfast — Oatmeal with Berries — 320 kcal ✓")
/// matching the meal rows on the reference Nutrition Today and Plan
/// screens. Tapping the card opens Add Food pre-scoped to this slot;
/// swiping/long-pressing an entry removes it via [onRemoveEntry].
class MealLogCard extends StatelessWidget {
  const MealLogCard({
    super.key,
    required this.meal,
    required this.onAddFood,
    required this.onRemoveEntry,
  });

  final MealLog meal;
  final VoidCallback onAddFood;
  final ValueChanged<String> onRemoveEntry;

  IconData get _icon => switch (meal.type) {
        MealType.breakfast => Icons.free_breakfast_rounded,
        MealType.lunch => Icons.lunch_dining_rounded,
        MealType.dinner => Icons.dinner_dining_rounded,
        MealType.snack => Icons.cookie_rounded,
      };

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: meal.isLogged ? AppColors.successSurface : AppColors.primarySurface,
                  borderRadius: AppRadius.smRadius,
                ),
                child: Icon(
                  _icon,
                  size: 18,
                  color: meal.isLogged ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(meal.type.label, style: theme.textTheme.titleMedium),
              ),
              Text(
                '${meal.loggedCalories} / ${meal.targetCalories} kcal',
                style: theme.textTheme.bodySmall,
              ),
              IconButton(
                onPressed: onAddFood,
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: AppColors.primary,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (meal.entries.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1, color: AppColors.ink100),
            const SizedBox(height: AppSpacing.sm),
            ...meal.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Dismissible(
                  key: ValueKey(entry.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => onRemoveEntry(entry.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 4),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '${entry.foodName} · ${entry.quantityLabel}',
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('${entry.calories} kcal', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
