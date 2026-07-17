import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/dashboard_summary.dart';

class TodaysPlanSection extends StatelessWidget {
  const TodaysPlanSection({super.key, required this.meals});

  final List<MealSlot> meals;

  IconData _iconFor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.free_breakfast_rounded;
      case MealType.lunch:
        return Icons.lunch_dining_rounded;
      case MealType.dinner:
        return Icons.dinner_dining_rounded;
      case MealType.snack:
        return Icons.cookie_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Plan", style: theme.textTheme.headlineMedium),
            TextButton(
              onPressed: () => context.push('/nutrition'),
              child: const Text('See all'),
            ),
          ],
        ),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: meals.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final meal = meals[index];
              return Container(
                width: 128,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.lgRadius,
                  boxShadow: AppElevation.card(AppColors.ink900),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: meal.isLogged
                            ? AppColors.successSurface
                            : AppColors.primarySurface,
                        borderRadius: AppRadius.smRadius,
                      ),
                      child: Icon(
                        _iconFor(meal.type),
                        size: 16,
                        color: meal.isLogged ? AppColors.success : AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(meal.label, style: theme.textTheme.titleSmall),
                    Text(
                      meal.isLogged ? '${meal.calories} kcal' : 'Not logged',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
