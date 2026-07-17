import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/onboarding_answers.dart';
import 'onboarding_providers.dart';

/// The five onboarding steps, in display order. [OnboardingFlowState.step]
/// indexes into this conceptually — kept as a plain int rather than an enum
/// index reference so the progress bar can do simple math on it.
const int onboardingStepCount = 5;

class OnboardingFlowState {
  const OnboardingFlowState({
    this.step = 0,
    this.answers = const OnboardingAnswers(),
    this.isSubmitting = false,
    this.failure,
    this.completed = false,
  });

  final int step;
  final OnboardingAnswers answers;
  final bool isSubmitting;
  final Failure? failure;
  final bool completed;

  bool get isFirstStep => step == 0;
  bool get isLastStep => step == onboardingStepCount - 1;
  double get progress => (step + 1) / onboardingStepCount;

  OnboardingFlowState copyWith({
    int? step,
    OnboardingAnswers? answers,
    bool? isSubmitting,
    Failure? failure,
    bool clearFailure = false,
    bool? completed,
  }) {
    return OnboardingFlowState(
      step: step ?? this.step,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: clearFailure ? null : (failure ?? this.failure),
      completed: completed ?? this.completed,
    );
  }
}

class OnboardingController extends Notifier<OnboardingFlowState> {
  @override
  OnboardingFlowState build() => const OnboardingFlowState();

  void updateAnswers(OnboardingAnswers Function(OnboardingAnswers current) update) {
    state = state.copyWith(answers: update(state.answers));
  }

  void next() {
    if (state.isLastStep) {
      _submit();
      return;
    }
    state = state.copyWith(step: state.step + 1);
  }

  void back() {
    if (state.isFirstStep) return;
    state = state.copyWith(step: state.step - 1);
  }

  Future<void> _submit() async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    final result = await ref.read(onboardingRepositoryProvider).completeOnboarding(state.answers);
    state = result.fold(
      (failure) => state.copyWith(isSubmitting: false, failure: failure),
      (_) => state.copyWith(isSubmitting: false, completed: true),
    );
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingFlowState>(OnboardingController.new);
