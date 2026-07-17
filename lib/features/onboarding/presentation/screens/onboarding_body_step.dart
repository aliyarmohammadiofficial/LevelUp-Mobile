import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/onboarding_controller.dart';
import '../widgets/onboarding_step_scaffold.dart';

class OnboardingBodyStep extends ConsumerStatefulWidget {
  const OnboardingBodyStep({super.key});

  @override
  ConsumerState<OnboardingBodyStep> createState() => _OnboardingBodyStepState();
}

class _OnboardingBodyStepState extends ConsumerState<OnboardingBodyStep> {
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _targetController;

  @override
  void initState() {
    super.initState();
    final answers = ref.read(onboardingControllerProvider).answers;
    _heightController = TextEditingController(text: answers.heightCm?.toStringAsFixed(0) ?? '');
    _weightController =
        TextEditingController(text: answers.currentWeightKg?.toStringAsFixed(1) ?? '');
    _targetController =
        TextEditingController(text: answers.targetWeightKg?.toStringAsFixed(1) ?? '');

    for (final c in [_heightController, _weightController, _targetController]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    for (final c in [_heightController, _weightController, _targetController]) {
      c.removeListener(_onFieldChanged);
      c.dispose();
    }
    super.dispose();
  }

  bool get _isValid {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final needsTarget = ref.read(onboardingControllerProvider).answers.hasWeightGoal;
    final target = double.tryParse(_targetController.text);
    if (height == null || height <= 0) return false;
    if (weight == null || weight <= 0) return false;
    if (needsTarget && (target == null || target <= 0)) return false;
    return true;
  }

  void _onContinue() {
    final controller = ref.read(onboardingControllerProvider.notifier);
    controller.updateAnswers((a) => a.copyWith(
          heightCm: double.tryParse(_heightController.text),
          currentWeightKg: double.tryParse(_weightController.text),
          targetWeightKg: double.tryParse(_targetController.text),
        ));
    controller.next();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final needsTarget = state.answers.hasWeightGoal;

    return OnboardingStepScaffold(
      progress: state.progress,
      title: 'Tell us about your body',
      subtitle: 'Used to personalize your calorie and activity targets.',
      isContinueEnabled: _isValid,
      onBack: controller.back,
      onContinue: _onContinue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            label: 'Height (cm)',
            controller: _heightController,
            hint: 'e.g. 170',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.height_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Current Weight (kg)',
            controller: _weightController,
            hint: 'e.g. 72.5',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.monitor_weight_outlined,
          ),
          if (needsTarget) ...[
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Target Weight (kg)',
              controller: _targetController,
              hint: 'e.g. 65',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.flag_outlined,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            'You can change these anytime in Settings.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.ink500),
          ),
        ],
      ),
    );
  }
}
