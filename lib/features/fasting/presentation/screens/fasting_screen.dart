import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/mascot.dart';
import '../../../dashboard/presentation/widgets/dashboard_tip_card.dart';
import '../../../workout/presentation/widgets/routine_tab_bar.dart';
import '../../domain/entities/fasting_entities.dart';
import '../providers/fasting_providers.dart';
import '../widgets/fasting_history_tile.dart';
import '../widgets/fasting_plan_card.dart';
import '../widgets/fasting_timer_ring.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

/// Top-level Fasting screen, reached from the Dashboard's fasting card or
/// bottom-nav quick actions. Segmented Timer / History view, matching the
/// app's established pattern (see Nutrition's Today/Plan/Insights tabs)
/// so a live countdown and a fasting log both live under one destination.
class FastingScreen extends ConsumerStatefulWidget {
  const FastingScreen({super.key});

  @override
  ConsumerState<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends ConsumerState<FastingScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Timer', 'History'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fasting')),
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
                child: _tabIndex == 0 ? const _TimerTab() : const _HistoryTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerTab extends ConsumerWidget {
  const _TimerTab();

  Future<void> _showPlanPicker(BuildContext context, WidgetRef ref) async {
    final plans = ref.read(fastingPlansProvider);
    var selected = plans.first;

    final chosen = await showModalBottomSheet<FastingPlan>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choose a Plan', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  ...plans.map(
                    (plan) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: FastingPlanCard(
                        plan: plan,
                        isSelected: plan.id == selected.id,
                        onTap: () => setSheetState(() => selected = plan),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Start Fast',
                    onPressed: () => Navigator.of(context).pop(selected),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (chosen != null) {
      await ref.read(fastingRepositoryProvider).startFast(chosen);
      ref.invalidate(fastingSessionProvider);
    }
  }

  Future<void> _confirmEndFast(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End fast early?'),
        content: const Text("You haven't reached your goal yet. End the fast now?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('End Fast'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(fastingRepositoryProvider).endFastEarly();
      ref.invalidate(fastingSessionProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(fastingSessionProvider);
    final statsAsync = ref.watch(fastingStatsProvider);
    final theme = Theme.of(context);

    return sessionAsync.when(
      loading: () => const AppLoadingIndicator(),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascot(pose: MascotPose.sad, size: 96),
            const SizedBox(height: AppSpacing.md),
            Text("Couldn't load your fasting data.", style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
      data: (session) {
        if (session == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Mascot(pose: MascotPose.happy, size: 96),
                const SizedBox(height: AppSpacing.md),
                Text('No fast in progress', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Pick a plan to start your first fast.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Start Fast',
                  onPressed: () => _showPlanPicker(context, ref),
                ),
              ],
            ),
          );
        }

        final now = DateTime.now();
        final isEatingWindow = session.state == FastingSessionState.eatingWindow;

        return ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: FastingTimerRing(session: session, now: now),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(
                  label: 'Started',
                  value: TimeOfDay.fromDateTime(session.startedAt).format(context),
                ),
                _MiniStat(
                  label: isEatingWindow ? 'Window Ends' : 'Fast Ends',
                  value: TimeOfDay.fromDateTime(
                    isEatingWindow ? session.eatingWindowEndsAt : session.fastEndsAt,
                  ).format(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: isEatingWindow ? 'Start Next Fast' : 'End Fast Early',
              variant: isEatingWindow ? AppButtonVariant.primary : AppButtonVariant.outlined,
              onPressed: () => isEatingWindow
                  ? _showPlanPicker(context, ref)
                  : _confirmEndFast(context, ref),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Change Plan',
              variant: AppButtonVariant.text,
              onPressed: () => _showPlanPicker(context, ref),
            ),
            const SizedBox(height: AppSpacing.lg),
            statsAsync.when(
              data: (stats) => Row(
                children: [
                  Expanded(
                    child: _StreakCard(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Current Streak',
                      value: '${stats.currentStreakDays} days',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StreakCard(
                      icon: Icons.emoji_events_rounded,
                      label: 'Best Streak',
                      value: '${stats.bestStreakDays} days',
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.lg),
            const DashboardTipCard(
              tip: 'Staying hydrated during your fast helps curb hunger.',
            ),
          ],
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.ink500)),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

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
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: theme.textTheme.titleLarge),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.ink500)),
        ],
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(fastingHistoryProvider);
    final theme = Theme.of(context);

    return historyAsync.when(
      loading: () => const AppLoadingIndicator(),
      error: (error, stack) => Center(
        child: Text("Couldn't load history.", style: theme.textTheme.bodyMedium),
      ),
      data: (history) {
        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Mascot(pose: MascotPose.sleepy, size: 96),
                const SizedBox(height: AppSpacing.md),
                Text('No fasts logged yet.', style: theme.textTheme.bodyMedium),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          itemCount: history.length,
          itemBuilder: (context, index) => FastingHistoryTile(entry: history[index]),
        );
      },
    );
  }
}
