import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/onboarding_answers.dart';
import '../providers/onboarding_controller.dart';
import '../widgets/onboarding_option_card.dart';
import '../widgets/onboarding_step_scaffold.dart';

class OnboardingGoalStep extends ConsumerWidget {
  const OnboardingGoalStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingStepScaffold(
      progress: state.progress,
      title: "What's your main goal?",
      subtitle: "We'll tailor your plan around this.",
      isContinueEnabled: state.answers.goal != null,
      onBack: controller.back,
      onContinue: controller.next,
      child: Column(
        children: [
          OnboardingOptionCard(
            icon: Icons.trending_down_rounded,
            title: 'Lose Weight',
            subtitle: 'Burn fat and slim down',
            isSelected: state.answers.goal == FitnessGoal.loseWeight,
            onTap: () => controller.updateAnswers(
              (a) => a.copyWith(goal: FitnessGoal.loseWeight),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OnboardingOptionCard(
            icon: Icons.fitness_center_rounded,
            title: 'Build Muscle',
            subtitle: 'Gain strength and size',
            isSelected: state.answers.goal == FitnessGoal.buildMuscle,
            onTap: () => controller.updateAnswers(
              (a) => a.copyWith(goal: FitnessGoal.buildMuscle),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OnboardingOptionCard(
            icon: Icons.balance_rounded,
            title: 'Maintain Weight',
            subtitle: 'Stay healthy and consistent',
            isSelected: state.answers.goal == FitnessGoal.maintain,
            onTap: () => controller.updateAnswers(
              (a) => a.copyWith(goal: FitnessGoal.maintain),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OnboardingOptionCard(
            icon: Icons.directions_run_rounded,
            title: 'Improve Endurance',
            subtitle: 'Build stamina and cardio fitness',
            isSelected: state.answers.goal == FitnessGoal.improveEndurance,
            onTap: () => controller.updateAnswers(
              (a) => a.copyWith(goal: FitnessGoal.improveEndurance),
            ),
          ),
        ],
      ),
    );
  }
}
