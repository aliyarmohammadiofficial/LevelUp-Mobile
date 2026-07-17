import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/copyright_footer.dart';
import '../../../../core/widgets/mascot.dart';
import '../../../onboarding/domain/entities/onboarding_answers.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

/// Real Goals screen — shows the user's actual fitness goal, weight
/// target, activity level, and daily targets as saved during onboarding,
/// instead of a placeholder.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answersAsync = ref.watch(savedOnboardingAnswersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: SafeArea(
        child: answersAsync.when(
          data: (answers) {
            if (answers == null) {
              return _EmptyGoals(onSetGoals: () => context.push('/onboarding'));
            }
            return _GoalsContent(answers: answers);
          },
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
                    "Couldn't load your goals.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => ref.invalidate(savedOnboardingAnswersProvider),
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

class _GoalsContent extends StatelessWidget {
  const _GoalsContent({required this.answers});

  final OnboardingAnswers answers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = answers.currentWeightKg;
    final target = answers.targetWeightKg;
    final hasWeightTrack = current != null && target != null;
    final remainingKg = hasWeightTrack ? (current - target) : null;
    // Rough visual indicator of closeness to goal — not a precise
    // percentage without knowing the starting weight, but gives a
    // reasonable sense of progress from the current reading alone.
    final progress = hasWeightTrack && current > 0
        ? (1 - (remainingKg!.abs() / current)).clamp(0.0, 1.0)
        : null;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(
        top: AppSpacing.xl,
        bottom: AppSpacing.xxxl,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppRadius.xlRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Goal',
                style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                answers.goal?.label ?? 'Not set',
                style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white),
              ),
              if (hasWeightTrack) ...[
                const SizedBox(height: AppSpacing.lg),
                ClipRRect(
                  borderRadius: AppRadius.pillRadius,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  remainingKg! == 0
                      ? "You're at your goal weight!"
                      : '${remainingKg.abs().toStringAsFixed(1)} kg to ${remainingKg > 0 ? 'lose' : 'gain'}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(duration: AppMotion.standard).slideY(begin: -0.05, end: 0, curve: AppMotion.enterCurve),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Current Weight',
                value: current != null ? '${current.toStringAsFixed(1)} kg' : '—',
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _StatTile(
                label: 'Target Weight',
                value: target != null ? '${target.toStringAsFixed(1)} kg' : '—',
              ),
            ),
          ],
        ).animate().fadeIn(delay: 80.ms, duration: AppMotion.standard),
        const SizedBox(height: AppSpacing.xl),
        _InfoCard(
          rows: [
            _Row('Activity Level', answers.activityLevel?.label ?? 'Not set'),
            _Row('Workout Days / Week', '${answers.workoutDaysPerWeek}'),
            _Row('Daily Water Goal', '${answers.dailyWaterCupsGoal} cups'),
          ],
        ).animate().fadeIn(delay: 140.ms, duration: AppMotion.standard),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: TextButton(
            onPressed: () => context.push('/onboarding'),
            child: const Text('Update my goals'),
          ),
        ),
        const CopyrightFooter(),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppElevation.card(AppColors.ink900),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: AppColors.ink500)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _Row {
  const _Row(this.label, this.value);
  final String label;
  final String value;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.xlRadius,
        boxShadow: AppElevation.card(AppColors.ink900),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(rows[i].label, style: theme.textTheme.bodyMedium),
                  Text(rows[i].value, style: theme.textTheme.titleSmall),
                ],
              ),
            ),
            if (i != rows.length - 1)
              const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _EmptyGoals extends StatelessWidget {
  const _EmptyGoals({required this.onSetGoals});
  final VoidCallback onSetGoals;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascot(pose: MascotPose.sleepy, size: 100),
            const SizedBox(height: AppSpacing.lg),
            Text(
              "You haven't set any goals yet.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(onPressed: onSetGoals, child: const Text('Set up my goals')),
          ],
        ),
      ),
    );
  }
}
