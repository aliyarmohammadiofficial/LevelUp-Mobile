import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';
import '../../../dashboard/presentation/widgets/dashboard_tip_card.dart';
import '../../../workout/presentation/widgets/routine_tab_bar.dart';
import '../../domain/entities/nutrition_entities.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/calorie_ring_card.dart';
import '../widgets/macro_bar_row.dart';
import '../widgets/meal_log_card.dart';
import 'edit_plan_screen.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

/// Top-level Nutrition tab: segmented Today / Plan / Insights view,
/// matching the reference "Nutrition" and "Nutrition Plan" screens.
class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  late int _tabIndex = widget.initialTabIndex;

  static const _tabs = ['Today', 'Plan', 'Insights'];

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(nutritionTodayProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoutineTabBar(
                tabs: _tabs,
                selectedIndex: _tabIndex,
                onSelected: (i) => setState(() => _tabIndex = i),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: todayAsync.when(
                  data: (day) => switch (_tabIndex) {
                    0 => _TodayTab(day: day),
                    1 => _PlanTab(day: day),
                    _ => const _InsightsTab(),
                  },
                  loading: () => const AppLoadingIndicator(),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Mascot(pose: MascotPose.sad, size: 96),
                        const SizedBox(height: AppSpacing.md),
                        Text("Couldn't load your nutrition data.",
                            style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayTab extends ConsumerWidget {
  const _TodayTab({required this.day});
  final NutritionDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        CalorieRingCard(
          consumed: day.caloriesLogged,
          goal: day.calorieGoal,
          progress: day.calorieProgress,
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgRadius,
            boxShadow: AppElevation.card(AppColors.ink900),
          ),
          child: Row(
            children: [
              MacroBarRow(
                label: 'Protein',
                consumedG: day.macroProgress.proteinG,
                targetG: day.macroTargets.proteinG,
                color: AppColors.chartProtein,
              ),
              const SizedBox(width: AppSpacing.lg),
              MacroBarRow(
                label: 'Carbs',
                consumedG: day.macroProgress.carbsG,
                targetG: day.macroTargets.carbsG,
                color: AppColors.chartCarbs,
              ),
              const SizedBox(width: AppSpacing.lg),
              MacroBarRow(
                label: 'Fat',
                consumedG: day.macroProgress.fatG,
                targetG: day.macroTargets.fatG,
                color: AppColors.chartFat,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text("Today's Meals", style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.md),
        ...day.meals.asMap().entries.map((e) {
          final index = e.key;
          final meal = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: MealLogCard(
              meal: meal,
              onAddFood: () => context.push('/nutrition/add-food?meal=${meal.type.name}'),
              onRemoveEntry: (entryId) => ref
                  .read(nutritionActionsProvider)
                  .removeEntry(meal: meal.type, entryId: entryId),
            ).animate().fadeIn(delay: (60 * index).ms, duration: AppMotion.standard).slideY(
                  begin: 0.05,
                  end: 0,
                  curve: AppMotion.enterCurve,
                ),
          );
        }),
      ],
    );
  }
}

class _PlanTab extends StatelessWidget {
  const _PlanTab({required this.day});
  final NutritionDay day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgRadius,
            boxShadow: AppElevation.card(AppColors.ink900),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Goal', style: theme.textTheme.bodySmall),
                    Text('${day.calorieGoal} kcal', style: theme.textTheme.headlineLarge),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EditPlanScreen(day: day)),
                ),
                icon: const Icon(Icons.edit_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primarySurface,
                  foregroundColor: AppColors.primary,
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Macro Targets', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgRadius,
            boxShadow: AppElevation.card(AppColors.ink900),
          ),
          child: Row(
            children: [
              MacroBarRow(
                label: 'Protein',
                consumedG: day.macroProgress.proteinG,
                targetG: day.macroTargets.proteinG,
                color: AppColors.chartProtein,
              ),
              const SizedBox(width: AppSpacing.lg),
              MacroBarRow(
                label: 'Carbs',
                consumedG: day.macroProgress.carbsG,
                targetG: day.macroTargets.carbsG,
                color: AppColors.chartCarbs,
              ),
              const SizedBox(width: AppSpacing.lg),
              MacroBarRow(
                label: 'Fat',
                consumedG: day.macroProgress.fatG,
                targetG: day.macroTargets.fatG,
                color: AppColors.chartFat,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Meals', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.md),
        ...day.meals.map(
          (meal) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.lgRadius,
              boxShadow: AppElevation.card(AppColors.ink900),
            ),
            child: Row(
              children: [
                Icon(
                  switch (meal.type) {
                    MealType.breakfast => Icons.free_breakfast_rounded,
                    MealType.lunch => Icons.lunch_dining_rounded,
                    MealType.dinner => Icons.dinner_dining_rounded,
                    MealType.snack => Icons.cookie_rounded,
                  },
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(meal.type.label, style: theme.textTheme.titleMedium)),
                Text('${meal.targetCalories} kcal', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => EditPlanScreen(day: day)),
            ),
            child: const Text('Edit Plan'),
          ),
        ),
      ],
    );
  }
}

class _InsightsTab extends ConsumerWidget {
  const _InsightsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(nutritionInsightsProvider);
    final theme = Theme.of(context);

    return insightsAsync.when(
      data: (insights) {
        final maxY = (insights.history.map((h) => h.calorieGoal).fold<int>(
                  0,
                  (a, b) => a > b ? a : b,
                ) *
                1.2)
            .toDouble();

        return ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          children: [
            Row(
              children: [
                Expanded(
                  child: _InsightStatCard(
                    label: 'Average',
                    value: '${insights.averageCalories} kcal',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _InsightStatCard(
                    label: 'Best Day',
                    value: '${insights.bestDayCalories} kcal',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _InsightStatCard(
                    label: 'Streak',
                    value: '${insights.loggingStreakDays} days',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('This Week', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.lgRadius,
                boxShadow: AppElevation.card(AppColors.ink900),
              ),
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= insights.history.length) {
                            return const SizedBox.shrink();
                          }
                          final label =
                              DateFormat.E().format(insights.history[index].date);
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(label, style: theme.textTheme.labelSmall),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: insights.history.asMap().entries.map((e) {
                    final point = e.value;
                    final overGoal = point.caloriesConsumed > point.calorieGoal;
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: point.caloriesConsumed.toDouble(),
                          color: overGoal ? AppColors.warning : AppColors.primary,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const DashboardTipCard(
              tip: 'Great consistency this week! Try adding a protein source to breakfast '
                  'to hit your target more often.',
            ),
          ],
        );
      },
      loading: () => const AppLoadingIndicator(),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascot(pose: MascotPose.sad, size: 96),
            const SizedBox(height: AppSpacing.md),
            Text("Couldn't load insights.", style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _InsightStatCard extends StatelessWidget {
  const _InsightStatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppElevation.card(AppColors.ink900),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
