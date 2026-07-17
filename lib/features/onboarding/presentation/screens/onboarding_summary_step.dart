import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/mascot.dart';
import '../../domain/entities/onboarding_answers.dart';
import '../providers/onboarding_controller.dart';
import '../widgets/onboarding_progress_bar.dart';

class OnboardingSummaryStep extends ConsumerStatefulWidget {
  const OnboardingSummaryStep({super.key});

  @override
  ConsumerState<OnboardingSummaryStep> createState() => _OnboardingSummaryStepState();
}

class _OnboardingSummaryStepState extends ConsumerState<OnboardingSummaryStep> {
  bool _showConfetti = false;

  String _goalLabel(FitnessGoal? goal) {
    switch (goal) {
      case FitnessGoal.loseWeight:
        return 'Lose Weight';
      case FitnessGoal.buildMuscle:
        return 'Build Muscle';
      case FitnessGoal.maintain:
        return 'Maintain Weight';
      case FitnessGoal.improveEndurance:
        return 'Improve Endurance';
      case null:
        return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final answers = state.answers;

    ref.listen(onboardingControllerProvider, (previous, next) {
      if (next.completed && previous?.completed != true) {
        // Play the brand confetti burst over the summary screen for a beat
        // before handing off to the dashboard, so "You're all set!" reads
        // as a genuine celebration rather than an instant redirect.
        setState(() => _showConfetti = true);
        Future.delayed(const Duration(milliseconds: 900), () {
          if (context.mounted) context.go('/dashboard');
        });
      }
      if (next.failure != null && next.failure != previous?.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.failure!.message)),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  IconButton(
                    onPressed: controller.back,
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primarySurface,
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: OnboardingProgressBar(progress: state.progress)),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Mascot(pose: MascotPose.celebrate, size: 130)
                            .animate()
                            .fadeIn(duration: AppMotion.slow)
                            .scale(
                              begin: const Offset(0.7, 0.7),
                              end: const Offset(1, 1),
                              curve: AppMotion.bounceCurve,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        "You're all set!",
                        style: theme.textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        "Here's your plan summary.",
                        style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.ink500),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      _SummaryCard(
                        rows: [
                          _SummaryRow(label: 'Goal', value: _goalLabel(answers.goal)),
                          _SummaryRow(
                            label: 'Height',
                            value: answers.heightCm != null
                                ? '${answers.heightCm!.toStringAsFixed(0)} cm'
                                : '—',
                          ),
                          _SummaryRow(
                            label: 'Current Weight',
                            value: answers.currentWeightKg != null
                                ? '${answers.currentWeightKg!.toStringAsFixed(1)} kg'
                                : '—',
                          ),
                          if (answers.hasWeightGoal)
                            _SummaryRow(
                              label: 'Target Weight',
                              value: answers.targetWeightKg != null
                                  ? '${answers.targetWeightKg!.toStringAsFixed(1)} kg'
                                  : '—',
                            ),
                          _SummaryRow(
                            label: 'Workout Days',
                            value: '${answers.workoutDaysPerWeek} days/week',
                          ),
                          _SummaryRow(
                            label: 'Water Goal',
                            value: '${answers.dailyWaterCupsGoal} cups/day',
                          ),
                        ],
                      ).animate().fadeIn(delay: 150.ms, duration: AppMotion.standard),
                    ],
                  ),
                ),
              ),
              AppButton(
                label: 'Start My Journey',
                isLoading: state.isSubmitting,
                onPressed: controller.next,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
            ),
            if (_showConfetti)
              Positioned.fill(
                child: IgnorePointer(
                  child: Lottie.asset(
                    AssetPaths.confettiAnimation,
                    repeat: false,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.rows});
  final List<_SummaryRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppElevation.card(AppColors.ink900),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}
