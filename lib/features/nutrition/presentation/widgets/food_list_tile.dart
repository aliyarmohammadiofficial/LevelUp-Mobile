import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/nutrition_entities.dart';

/// One row in the Add Food search results / recents list — food name,
/// serving size, calories, and a quick-add button, matching the reference
/// Add Food screen's "Oatmeal — 150 kcal" style rows.
class FoodListTile extends StatelessWidget {
  const FoodListTile({super.key, required this.food, required this.onAdd, this.onDelete});

  final FoodItem food;
  final VoidCallback onAdd;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: AppRadius.lgRadius,
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgRadius,
          boxShadow: AppElevation.card(AppColors.ink900),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppRadius.smRadius,
              ),
              child: const Icon(Icons.restaurant_rounded, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name, style: theme.textTheme.titleMedium),
                  Text(
                    '${food.servingLabel} · ${food.caloriesPerServing} kcal',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.ink500,
                tooltip: 'Delete',
              ),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_rounded),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
