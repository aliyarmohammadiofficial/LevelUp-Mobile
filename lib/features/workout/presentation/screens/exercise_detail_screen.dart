import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/mascot.dart';
import '../providers/workout_providers.dart';
import '../widgets/muscle_diagram.dart';

/// Matches the reference "Bench Press" exercise detail screen: hero card,
/// numbered "How to perform" steps, and the "Muscles Worked" body diagram
/// with set/rep meta chips, ending in a Start Set button.
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.routineId, required this.exerciseId});

  final String routineId;
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise =
        ref.watch(exerciseByIdProvider((routineId: routineId, exerciseId: exerciseId)));
    final routine = ref.watch(routineByIdProvider(routineId));
    final theme = Theme.of(context);

    if (exercise == null || routine == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercise')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Mascot(pose: MascotPose.sad, size: 96),
              const SizedBox(height: AppSpacing.md),
              Text("Couldn't find that exercise.", style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
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
                      color: AppColors.surface,
                      borderRadius: AppRadius.xlRadius,
                      boxShadow: AppElevation.card(AppColors.ink900),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(exercise.name, style: theme.textTheme.headlineLarge),
                              const SizedBox(height: 2),
                              Text(routine.name, style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                        const Mascot(pose: MascotPose.sleepy, size: 64, animate: false),
                      ],
                    ),
                  ).animate().fadeIn(duration: AppMotion.standard),
                  const SizedBox(height: AppSpacing.xl),
                  if (exercise.instructions.isNotEmpty) ...[
                    Text('How to perform', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.md),
                    ...exercise.instructions.asMap().entries.map((entry) {
                      final i = entry.key;
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(top: 2),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: AppColors.primarySurface,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${i + 1}',
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: Text(step, style: theme.textTheme.bodyMedium)),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Text('Muscles Worked', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.lgRadius,
                      boxShadow: AppElevation.card(AppColors.ink900),
                    ),
                    child: MuscleDiagram(muscles: exercise.primaryMuscles),
                  ).animate().fadeIn(delay: 100.ms, duration: AppMotion.standard),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _MetaChip(
                          icon: Icons.layers_rounded,
                          label: '${exercise.targetSets} Sets',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _MetaChip(
                          icon: Icons.repeat_rounded,
                          label: exercise.repRangeLabel,
                        ),
                      ),
                    ],
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
                label: 'Start Set',
                onPressed: () => context.push('/workout/$routineId/$exerciseId/set'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppRadius.mdRadius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}
