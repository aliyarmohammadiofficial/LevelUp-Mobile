import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/dashboard_tip_card.dart';
import '../widgets/fasting_card.dart';
import '../widgets/todays_plan_section.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      body: SafeArea(
        child: summaryAsync.when(
          data: (summary) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardSummaryProvider),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(
                top: AppSpacing.lg,
                bottom: AppSpacing.xxxl,
              ),
              children: [
                DashboardHeader(userName: summary.userDisplayName)
                    .animate()
                    .fadeIn(duration: AppMotion.standard)
                    .slideY(begin: -0.06, end: 0, curve: AppMotion.enterCurve),
                const SizedBox(height: AppSpacing.xxl),
                FastingCard(status: summary.fasting)
                    .animate()
                    .fadeIn(delay: 80.ms, duration: AppMotion.standard)
                    .slideY(begin: 0.08, end: 0, curve: AppMotion.enterCurve),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: DashboardStatCard(
                        icon: Icons.fitness_center_rounded,
                        label: 'Workout',
                        valueLabel:
                            '${summary.workout.completedCount} of ${summary.workout.totalCount} completed',
                        progress: summary.workout.progress,
                        progressColor: AppColors.primary,
                        route: '/workout',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: DashboardStatCard(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Calories',
                        valueLabel: '${summary.calories.consumed}/${summary.calories.goal} kcal',
                        progress: summary.calories.progress,
                        progressColor: AppColors.warning,
                        route: '/nutrition',
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 140.ms, duration: AppMotion.standard),
                const SizedBox(height: AppSpacing.xxl),
                TodaysPlanSection(meals: summary.todaysMeals)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: AppMotion.standard),
                const SizedBox(height: AppSpacing.xxl),
                DashboardTipCard(tip: summary.tip)
                    .animate()
                    .fadeIn(delay: 260.ms, duration: AppMotion.standard),
              ],
            ),
          ),
          loading: () => const AppLoadingIndicator(),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Mascot(pose: MascotPose.sad, size: 100),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    "Couldn't load your dashboard.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => ref.invalidate(dashboardSummaryProvider),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
