import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';
import '../../domain/entities/water_entities.dart';
import '../providers/water_providers.dart';
import '../widgets/cup_grid.dart';
import '../widgets/water_ring.dart';
import '../widgets/water_week_strip.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

/// Water Tracker screen — reached from the Dashboard quick actions,
/// matching the reference "6 / 8 Cups" screen: a hero ring, a tappable
/// cup grid to log intake, a weekly glance strip, and a streak stat.
class WaterScreen extends ConsumerWidget {
  const WaterScreen({super.key});

  Future<void> _handleCupTap(BuildContext context, WidgetRef ref, WaterDay day, int newCount) async {
    final wasGoalMet = day.goalReached;
    final repo = ref.read(waterRepositoryProvider);

    if (newCount > day.cupsLogged) {
      await repo.logCup(count: newCount - day.cupsLogged);
    } else if (newCount < day.cupsLogged) {
      await repo.undoCup();
    }

    if (!context.mounted) return;
    final nowMet = newCount >= day.cupGoal;
    if (nowMet && !wasGoalMet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meow-velous! Daily water goal reached 🎉')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(waterTodayProvider);
    final statsAsync = ref.watch(waterStatsProvider);
    final historyAsync = ref.watch(waterWeekHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Water Tracker')),
      body: SafeArea(
        child: todayAsync.when(
          loading: () => const AppLoadingIndicator(),
          error: (error, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Mascot(pose: MascotPose.sad, size: 96),
                const SizedBox(height: AppSpacing.md),
                Text("Couldn't load your water data.", style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          data: (day) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg).copyWith(
                bottom: AppSpacing.xxxl,
              ),
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: WaterRing(cupsLogged: day.cupsLogged, cupGoal: day.cupGoal),
                  ),
                ),
                Center(
                  child: Text(
                    '${day.totalMl} ml logged today',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.ink500),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                CupGrid(
                  cupsLogged: day.cupsLogged,
                  cupGoal: day.cupGoal,
                  onCupTapped: (newCount) => _handleCupTap(context, ref, day, newCount),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: day.cupsLogged > 0
                            ? () => ref.read(waterRepositoryProvider).undoCup()
                            : null,
                        icon: const Icon(Icons.remove_rounded),
                        label: const Text('Remove Cup'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleCupTap(context, ref, day, day.cupsLogged + 1),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Cup'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                historyAsync.when(
                  data: (history) => WaterWeekStrip(entries: history),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.lg),
                statsAsync.when(
                  data: (stats) => Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: AppRadius.lgRadius,
                    ),
                    child: Row(
                      children: [
                        const Mascot(pose: MascotPose.celebrate, size: 44, animate: false),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            '${stats.currentStreakDays} day streak · avg ${stats.averageCupsPerDay.toStringAsFixed(1)} cups/day',
                            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink900),
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
