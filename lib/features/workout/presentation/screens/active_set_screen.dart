import 'dart:async';
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
import '../providers/workout_providers.dart';
import '../widgets/set_value_stepper.dart';

/// Matches the reference Active Set screen: "Bench Press / Set 2 of 4",
/// large reps/weight steppers, "Mark as Completed", and a rest timer.
class ActiveSetScreen extends ConsumerStatefulWidget {
  const ActiveSetScreen({super.key, required this.routineId, required this.exerciseId});

  final String routineId;
  final String exerciseId;

  @override
  ConsumerState<ActiveSetScreen> createState() => _ActiveSetScreenState();
}

class _ActiveSetScreenState extends ConsumerState<ActiveSetScreen> {
  int? _reps;
  double? _weightKg;
  Timer? _restTimer;
  int _restSecondsLeft = 0;
  static const int _restDurationSeconds = 60;
  bool _showSuccess = false;

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() => _restSecondsLeft = _restDurationSeconds);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsLeft <= 1) {
        timer.cancel();
        setState(() => _restSecondsLeft = 0);
      } else {
        setState(() => _restSecondsLeft -= 1);
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() => _restSecondsLeft = 0);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = ref.watch(
      exerciseByIdProvider((routineId: widget.routineId, exerciseId: widget.exerciseId)),
    );
    final theme = Theme.of(context);

    if (exercise == null || exercise.sets.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Set')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Mascot(pose: MascotPose.sad, size: 96),
              const SizedBox(height: AppSpacing.md),
              Text("Couldn't load this exercise.", style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    final activeIndex = ref
        .watch(activeSetIndexProvider(widget.exerciseId))
        .clamp(0, exercise.sets.length - 1);
    final currentSet = exercise.sets[activeIndex];
    final reps = _reps ?? currentSet.reps;
    final weightKg = _weightKg ?? currentSet.weightKg;

    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Set ${activeIndex + 1} of ${exercise.sets.length}',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: Mascot(
                  pose: currentSet.isCompleted ? MascotPose.celebrate : MascotPose.wave,
                  size: 120,
                ),
              ).animate().fadeIn(duration: AppMotion.standard),
              const SizedBox(height: AppSpacing.xxl),
              SetValueStepper(
                label: 'Reps',
                value: '$reps',
                onIncrement: () => setState(() => _reps = (reps + 1).clamp(0, 999)),
                onDecrement: () => setState(() => _reps = (reps - 1).clamp(0, 999)),
              ),
              const SizedBox(height: AppSpacing.lg),
              SetValueStepper(
                label: 'Weight (kg)',
                value: weightKg % 1 == 0 ? '${weightKg.toInt()}' : '$weightKg',
                onIncrement: () => setState(() => _weightKg = (weightKg + 2.5).clamp(0, 999)),
                onDecrement: () => setState(() => _weightKg = (weightKg - 2.5).clamp(0, 999)),
              ),
              const Spacer(),
              if (_restSecondsLeft > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rest Timer', style: theme.textTheme.bodySmall),
                        Text(
                          '00:${_restSecondsLeft.toString().padLeft(2, '0')}',
                          style: theme.textTheme.headlineLarge,
                        ),
                      ],
                    ),
                    TextButton(onPressed: _skipRest, child: const Text('Skip Rest')),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppButton(
                label: currentSet.isCompleted ? 'Set Completed' : 'Mark as Completed',
                onPressed: currentSet.isCompleted
                    ? null
                    : () async {
                        await ref.read(workoutRepositoryProvider).logSet(
                              routineId: widget.routineId,
                              exerciseId: widget.exerciseId,
                              setNumber: currentSet.setNumber,
                              reps: reps,
                              weightKg: weightKg,
                            );
                        ref.invalidate(workoutRoutinesProvider);
                        _startRestTimer();

                        setState(() => _showSuccess = true);
                        Future.delayed(const Duration(milliseconds: 900), () {
                          if (mounted) setState(() => _showSuccess = false);
                        });

                        final isLastSet = activeIndex == exercise.sets.length - 1;
                        if (!isLastSet) {
                          setState(() {
                            _reps = null;
                            _weightKg = null;
                          });
                          ref
                              .read(activeSetIndexProvider(widget.exerciseId).notifier)
                              .state = activeIndex + 1;
                        }
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
            ),
            if (_showSuccess)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: SizedBox(
                      width: 140,
                      height: 140,
                      child: Lottie.asset(
                        AssetPaths.successAnimation,
                        repeat: false,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
