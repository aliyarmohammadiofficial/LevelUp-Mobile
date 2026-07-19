import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/mascot.dart';
import '../providers/workout_providers.dart';
import '../widgets/exercise_list_tile.dart';
import 'create_custom_exercise_screen.dart';

/// Matches the reference "Workout Detail" screen: routine hero card
/// ("Push Day / Chest • Shoulders • Triceps / 6 Exercises") followed by the
/// numbered exercise list and a Start Workout button.
class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({super.key, required this.routineId});

  final String routineId;

  Future<void> _openCreateCustomExercise(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateCustomExerciseScreen(routineId: routineId),
      ),
    );
  }

  Future<void> _deleteExercise(BuildContext context, WidgetRef ref, String exerciseId) async {
    await ref
        .read(workoutActionsProvider)
        .deleteCustomExercise(routineId: routineId, exerciseId: exerciseId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routine = ref.watch(routineByIdProvider(routineId));
    final theme = Theme.of(context);

    if (routine == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout Detail')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Mascot(pose: MascotPose.sad, size: 96),
              const SizedBox(height: AppSpacing.md),
              Text("Couldn't find that routine.", style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Detail'),
        actions: [
          IconButton(
            tooltip: 'Create Custom Exercise',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openCreateCustomExercise(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: AppSpacing.screenPadding.copyWith(bottom: AppSpacing.xxxl),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: AppRadius.xlRadius,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                routine.name,
                                style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                routine.subtitle,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                '${routine.totalCount} Exercises',
                                style: theme.textTheme.labelMedium
                                    ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                              ),
                            ],
                          ),
                        ),
                        const Mascot(pose: MascotPose.celebrate, size: 56, animated: false),
                      ],
                    ),
                  ).animate().fadeIn(duration: AppMotion.standard).slideY(
                        begin: -0.05,
                        end: 0,
                        curve: AppMotion.enterCurve,
                      ),
                  const SizedBox(height: AppSpacing.xl),
                  ...routine.exercises.asMap().entries.map((entry) {
                    final i = entry.key;
                    final exercise = entry.value;
                    return Dismissible(
                      key: ValueKey(exercise.id),
                      direction: exercise.isCustom
                          ? DismissDirection.endToStart
                          : DismissDirection.none,
                      confirmDismiss: (_) async {
                        await _deleteExercise(context, ref, exercise.id);
                        return true;
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.errorSurface,
                          borderRadius: AppRadius.lgRadius,
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                      ),
                      child: ExerciseListTile(
                        index: i + 1,
                        exercise: exercise,
                        onTap: () => context.push('/workout/$routineId/${exercise.id}'),
                      ),
                    ).animate().fadeIn(delay: (50 * i).ms, duration: AppMotion.standard);
                  }),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => _openCreateCustomExercise(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Custom Exercise'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: AppButton(
                label: 'Start Workout',
                onPressed: () {
                  final firstExercise = routine.exercises.first;
                  context.push('/workout/$routineId/${firstExercise.id}/set');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

