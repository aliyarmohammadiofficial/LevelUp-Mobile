import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';
import '../providers/progress_providers.dart';
import '../widgets/body_measurements_list.dart';
import '../widgets/progress_stat_row.dart';
import '../widgets/progress_tab_bar.dart';
import '../widgets/weight_chart_card.dart';
import '../widgets/workout_log_list.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  static const _tabLabels = ['Overview', 'Weight', 'Body', 'Workouts'];

  Future<void> _showLogWeightDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final weight = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Weight'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: 'kg'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              Navigator.of(context).pop(value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (weight != null && weight > 0) {
      await ref.read(progressRepositoryProvider).logWeight(weight);
      ref.invalidate(progressSummaryProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(progressSummaryProvider);
    final selectedTab = ref.watch(progressTabProvider);

    final isBodyTab = selectedTab == 2;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => isBodyTab
            ? context.push('/progress/measurements')
            : _showLogWeightDialog(context, ref),
        icon: Icon(isBodyTab ? Icons.straighten_rounded : Icons.monitor_weight_outlined),
        label: Text(isBodyTab ? 'Update Measurements' : 'Log Weight'),
      ),
      body: SafeArea(
        child: summaryAsync.when(
          data: (summary) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(progressSummaryProvider),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(
                top: AppSpacing.lg,
                bottom: AppSpacing.xxxl,
              ),
              children: [
                Text('Progress', style: Theme.of(context).textTheme.headlineLarge)
                    .animate()
                    .fadeIn(duration: AppMotion.standard)
                    .slideY(begin: -0.06, end: 0, curve: AppMotion.enterCurve),
                const SizedBox(height: AppSpacing.lg),
                ProgressTabBar(
                  labels: _tabLabels,
                  selectedIndex: selectedTab,
                  onChanged: (index) => ref.read(progressTabProvider.notifier).state = index,
                ).animate().fadeIn(delay: 60.ms, duration: AppMotion.standard),
                const SizedBox(height: AppSpacing.xl),
                _TabContent(tab: selectedTab, summary: summary)
                    .animate()
                    .fadeIn(delay: 120.ms, duration: AppMotion.standard)
                    .slideY(begin: 0.05, end: 0, curve: AppMotion.enterCurve),
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
                    "Couldn't load your progress.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => ref.invalidate(progressSummaryProvider),
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

class _TabContent extends StatelessWidget {
  const _TabContent({required this.tab, required this.summary});

  final int tab;
  final dynamic summary;

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case 1: // Weight
        return Column(
          key: const ValueKey('weight'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeightChartCard(
              currentWeightKg: summary.currentWeightKg,
              weightChangeKg: summary.weightChangeKg,
              periodLabel: summary.weightChangePeriodLabel,
              history: summary.weightHistory,
            ),
            const SizedBox(height: AppSpacing.lg),
            ProgressStatRow(goalWeightKg: summary.goalWeightKg, bmi: summary.bmi),
          ],
        );
      case 2: // Body
        return BodyMeasurementsList(
          key: const ValueKey('body'),
          measurements: summary.bodyMeasurements,
          updatedAt: summary.bodyMeasurementsUpdatedAt,
          onUpdate: () => context.push('/progress/measurements'),
        );
      case 3: // Workouts
        return WorkoutLogList(key: const ValueKey('workouts'), entries: summary.weeklyWorkouts);
      case 0: // Overview
      default:
        return Column(
          key: const ValueKey('overview'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeightChartCard(
              currentWeightKg: summary.currentWeightKg,
              weightChangeKg: summary.weightChangeKg,
              periodLabel: summary.weightChangePeriodLabel,
              history: summary.weightHistory,
            ),
            const SizedBox(height: AppSpacing.lg),
            ProgressStatRow(goalWeightKg: summary.goalWeightKg, bmi: summary.bmi),
            const SizedBox(height: AppSpacing.xxl),
            Text('This Week', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            WorkoutLogList(entries: summary.weeklyWorkouts),
          ],
        );
    }
  }
}
