import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/onboarding_answers.dart';
import '../providers/onboarding_controller.dart';
import '../widgets/onboarding_option_card.dart';
import '../widgets/onboarding_step_scaffold.dart';

class OnboardingSexStep extends ConsumerWidget {
  const OnboardingSexStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return OnboardingStepScaffold(
      progress: state.progress,
      title: "What's your sex?",
      subtitle: 'This helps us calibrate your calorie and macro targets.',
      isContinueEnabled: state.answers.sex != null,
      onBack: () => context.pop(),
      onContinue: controller.next,
      child: Column(
        children: [
          OnboardingOptionCard(
            icon: Icons.female_rounded,
            title: 'Female',
            isSelected: state.answers.sex == BiologicalSex.female,
            onTap: () => controller.updateAnswers(
              (a) => a.copyWith(sex: BiologicalSex.female),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OnboardingOptionCard(
            icon: Icons.male_rounded,
            title: 'Male',
            isSelected: state.answers.sex == BiologicalSex.male,
            onTap: () => controller.updateAnswers(
              (a) => a.copyWith(sex: BiologicalSex.male),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OnboardingOptionCard(
            icon: Icons.remove_red_eye_outlined,
            title: 'Prefer not to say',
            isSelected: state.answers.sex == BiologicalSex.preferNotToSay,
            onTap: () => controller.updateAnswers(
              (a) => a.copyWith(sex: BiologicalSex.preferNotToSay),
            ),
          ),
        ],
      ),
    );
  }
}
