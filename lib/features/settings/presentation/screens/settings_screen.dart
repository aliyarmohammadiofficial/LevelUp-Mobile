import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_option_picker.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickUnitSystem(BuildContext context, WidgetRef ref, AppSettings settings) async {
    final picked = await showSettingsOptionPicker<UnitSystem>(
      context: context,
      title: 'Units',
      selected: settings.unitSystem,
      options: [
        for (final system in UnitSystem.values)
          SettingsOption(value: system, label: system.label),
      ],
    );
    if (picked != null) {
      await ref.read(settingsControllerProvider.notifier).setUnitSystem(picked);
    }
  }

  Future<void> _pickThemeMode(BuildContext context, WidgetRef ref, AppSettings settings) async {
    final picked = await showSettingsOptionPicker<AppThemeMode>(
      context: context,
      title: 'Theme',
      selected: settings.themeMode,
      options: [
        for (final mode in AppThemeMode.values)
          SettingsOption(value: mode, label: mode.label),
      ],
    );
    if (picked != null) {
      await ref.read(settingsControllerProvider.notifier).setThemeMode(picked);
    }
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref, AppSettings settings) async {
    final picked = await showSettingsOptionPicker<AppLanguage>(
      context: context,
      title: 'Language',
      selected: settings.language,
      options: [
        for (final language in AppLanguage.values)
          SettingsOption(value: language, label: language.label),
      ],
    );
    if (picked != null) {
      await ref.read(settingsControllerProvider.notifier).setLanguage(picked);
    }
  }

  void _syncNow(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You're all caught up — everything is synced.")),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: settingsAsync.when(
          data: (settings) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(
              top: AppSpacing.sm,
              bottom: AppSpacing.xxxl,
            ),
            children: [
              SettingsSection(
                title: 'Preferences',
                children: [
                  SettingsTile.navigation(
                    label: 'Units',
                    value: settings.unitSystem.label,
                    onTap: () => _pickUnitSystem(context, ref, settings),
                  ),
                  SettingsTile.navigation(
                    label: 'Theme',
                    value: settings.themeMode.label,
                    onTap: () => _pickThemeMode(context, ref, settings),
                  ),
                  SettingsTile.navigation(
                    label: 'Language',
                    value: settings.language.label,
                    onTap: () => _pickLanguage(context, ref, settings),
                  ),
                ],
              ).animate().fadeIn(duration: AppMotion.standard),
              const SizedBox(height: AppSpacing.xl),
              SettingsSection(
                title: 'Notifications',
                children: [
                  SettingsTile.toggle(
                    label: 'Notifications',
                    toggleValue: settings.notificationsEnabled,
                    onToggleChanged: (value) =>
                        ref.read(settingsControllerProvider.notifier).setNotificationsEnabled(value),
                  ),
                  SettingsTile.toggle(
                    label: 'Sounds',
                    toggleValue: settings.soundsEnabled,
                    onToggleChanged: (value) =>
                        ref.read(settingsControllerProvider.notifier).setSoundsEnabled(value),
                  ),
                ],
              ).animate().fadeIn(delay: 60.ms, duration: AppMotion.standard),
              const SizedBox(height: AppSpacing.xl),
              SettingsSection(
                title: 'Data & Privacy',
                children: [
                  SettingsTile.navigation(
                    label: 'Data Sync',
                    value: 'Up to date',
                    onTap: () => _syncNow(context),
                  ),
                  SettingsTile.navigation(
                    label: 'Privacy Policy',
                    onTap: () => context.push('/settings/privacy-policy'),
                  ),
                ],
              ).animate().fadeIn(delay: 120.ms, duration: AppMotion.standard),
            ],
          ),
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
                    "Couldn't load your settings.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => ref.invalidate(settingsControllerProvider),
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
