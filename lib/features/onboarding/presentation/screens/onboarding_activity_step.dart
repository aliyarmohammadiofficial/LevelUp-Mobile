import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/onboarding_answers.dart';
import '../providers/onboarding_controller.dart';
import '../widgets/onboarding_option_card.dart';
import '../widgets/onboarding_step_scaffold.dart';

class OnboardingActivityStep extends ConsumerWidget {
  const OnboardingActivityStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingStepScaffold(
      progress: state.progress,
      title: 'How active are you?',
      subtitle: 'Be honest — this sets your daily calorie baseline.',
      isContinueEnabled: state.answers.activityLevel != null,
      onBack: controller.back,
      onContinue: controller.next,
      continueLabel: 'Continue',
      child: Column(
        children: [
          OnboardingOptionCard(
            icon: Icons.weekend_outlined,
            title: 'Sedentary',
            subtitle: 'Little to no exercise, desk job',
            isSelected: state.answers.activityLevel == ActivityLevel.sedentary,
            onTap: () => controller.updateAnswers(
              (a) => a.copyWith(activityLevel: ActivityLevel.sedentary),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OnboardingOptionCard(
            icon: Icons.directions_walk_rounded,
            title: 'Lightly Active',
            subtitle: 'Light exercise 1–3 days/week',
            isSelected: state.answers.activityLevel == ActivityLevel.light,
            onTap: () => controller.updateAnswers(
              (a) => a.copyWith(activityLevel: ActivityLevel.light),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OnboardingOptionCard(
            icon: Icons.directions_bike_rounded,
            title: 'Moderately Active',
            subtitle: 'Moderate exercise 3–5 days/week',
            isSelected: state.answers.activityLevel == ActivityLevel.moderate,
            onTap: () => controller.updateAnswers(
              (a) => a.copyWith(activityLevel: ActivityLevel.moderate),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OnboardingOptionCard(
            icon: Icons.fitness_center_rounded,
            title: 'Very Active',
            subtitle: 'Hard exercise 6–7 days/week',
            isSelected: state.answers.activityLevel == ActivityLevel.active,
            onTap: () => controller.updateAnswers(
              (a) => a.copyWith(activityLevel: ActivityLevel.active),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OnboardingOptionCard(
            icon: Icons.bolt_rounded,
            title: 'Extremely Active',
            subtitle: 'Physical job or twice-daily training',
            isSelected: state.answers.activityLevel == ActivityLevel.veryActive,
            onTap: () => controller.updateAnswers(
              (a) => a.copyWith(activityLevel: ActivityLevel.veryActive),
            ),
          ),
        ],
      ),
    );
  }
}
