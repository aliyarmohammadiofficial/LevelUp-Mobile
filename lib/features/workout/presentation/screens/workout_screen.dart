import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';
import '../../domain/entities/workout_routine.dart';
import '../providers/workout_providers.dart';
import '../widgets/routine_card.dart';
import '../widgets/routine_tab_bar.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

/// Top-level Workout tab: segmented Routines / Exercises / History view,
/// matching the reference "Workout" screen.
class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  int _tabIndex = 0;

  static const _tabs = ['Routines', 'Exercises', 'History'];

  @override
  Widget build(BuildContext context) {
    final routinesAsync = ref.watch(workoutRoutinesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
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
                child: routinesAsync.when(
                  data: (routines) => switch (_tabIndex) {
                    0 => _RoutinesTab(routines: routines),
                    1 => _ExercisesTab(routines: routines),
                    _ => _HistoryTab(routines: routines),
                  },
                  loading: () => const AppLoadingIndicator(),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Mascot(pose: MascotPose.sad, size: 96),
                        const SizedBox(height: AppSpacing.md),
                        Text("Couldn't load your workouts.", style: theme.textTheme.bodyMedium),
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

class _RoutinesTab extends StatelessWidget {
  const _RoutinesTab({required this.routines});
  final List<WorkoutRoutine> routines;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      itemCount: routines.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final routine = routines[index];
        return RoutineCard(
          routine: routine,
          onTap: () => context.push('/workout/${routine.id}'),
        ).animate().fadeIn(delay: (60 * index).ms, duration: AppMotion.standard).slideY(
              begin: 0.05,
              end: 0,
              curve: AppMotion.enterCurve,
            );
      },
    );
  }
}

class _ExercisesTab extends StatelessWidget {
  const _ExercisesTab({required this.routines});
  final List<WorkoutRoutine> routines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allExercises =
        routines.expand((r) => r.exercises.map((e) => (routine: r, exercise: e))).toList();

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      itemCount: allExercises.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final item = allExercises.elementAt(index);
        return InkWell(
          borderRadius: AppRadius.lgRadius,
          onTap: () => context.push('/workout/${item.routine.id}/${item.exercise.id}'),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.lgRadius,
              boxShadow: AppElevation.card(AppColors.ink900),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.exercise.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${item.routine.name} • ${item.exercise.targetSets} sets',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.ink300),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.routines});
  final List<WorkoutRoutine> routines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedRoutines = routines.where((r) => r.completedCount > 0).toList();

    if (completedRoutines.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascot(pose: MascotPose.sleepy, size: 96),
            const SizedBox(height: AppSpacing.lg),
            Text('No completed workouts yet', style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Finish a routine to see it here.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      itemCount: completedRoutines.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final routine = completedRoutines[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
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
                decoration: const BoxDecoration(
                  color: AppColors.successSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: AppColors.success),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(routine.name, style: theme.textTheme.titleMedium),
                    Text(
                      '${routine.completedCount}/${routine.totalCount} exercises completed',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
