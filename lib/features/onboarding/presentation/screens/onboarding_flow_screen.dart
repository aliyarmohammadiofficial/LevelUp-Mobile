import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_controller.dart';
import 'onboarding_activity_step.dart';
import 'onboarding_body_step.dart';
import 'onboarding_goal_step.dart';
import 'onboarding_sex_step.dart';
import 'onboarding_summary_step.dart';

/// Hosts the 5-step onboarding flow, swapping the visible step based on
/// [OnboardingFlowState.step]. Steps read/write the same controller rather
/// than being separate routes — keeps step transitions instant (no route
/// animation fighting the content fade) and keeps all answers in one place
/// until the final submit.
class OnboardingFlowScreen extends ConsumerWidget {
  const OnboardingFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(onboardingControllerProvider.select((s) => s.step));

    return PopScope(
      canPop: step == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ref.read(onboardingControllerProvider.notifier).back();
        }
      },
      child: IndexedStack(
        index: step,
        children: const [
          OnboardingSexStep(),
          OnboardingGoalStep(),
          OnboardingBodyStep(),
          OnboardingActivityStep(),
          OnboardingSummaryStep(),
        ],
      ),
    );
  }
}
