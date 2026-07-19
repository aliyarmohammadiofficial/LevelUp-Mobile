import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';
import '../../../settings/presentation/widgets/settings_section.dart';
import '../providers/reminders_providers.dart';
import '../widgets/reminder_tile.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

/// Reminders screen, reached from Profile → Reminders. Matches the
/// reference screen: a list of toggleable reminders (Workout, Meal,
/// Water, Bedtime, Weekly Report), each with a tap-to-edit time.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  Future<void> _editTime(BuildContext context, WidgetRef ref, String id, TimeOfDay current) async {
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked != null) {
      await ref.read(remindersControllerProvider.notifier).setTime(id, picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: SafeArea(
        child: remindersAsync.when(
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
                    "Couldn't load your reminders.",
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => ref.invalidate(remindersControllerProvider),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
          data: (reminders) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(
              top: AppSpacing.md,
              bottom: AppSpacing.xxxl,
            ),
            children: [
              SettingsSection(
                title: 'Daily',
                children: [
                  for (final reminder in reminders)
                    ReminderTile(
                      reminder: reminder,
                      onToggled: (value) =>
                          ref.read(remindersControllerProvider.notifier).setEnabled(reminder.id, value),
                      onEditTime: () => _editTime(context, ref, reminder.id, reminder.time),
                    ),
                ],
              ).animate().fadeIn(duration: AppMotion.standard),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppRadius.lgRadius,
                ),
                child: Row(
                  children: [
                    const Mascot(pose: MascotPose.wink, size: 48, animated: false),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Tap a reminder to change its time.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink900),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: AppMotion.standard),
            ],
          ),
        ),
      ),
    );
  }
}
