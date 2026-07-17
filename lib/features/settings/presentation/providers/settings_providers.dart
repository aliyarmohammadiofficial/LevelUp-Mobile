import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsLocalDataSourceProvider = Provider((ref) => SettingsLocalDataSource());

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(settingsLocalDataSourceProvider));
});

/// Loads persisted [AppSettings] once and exposes mutators that update
/// both storage and in-memory state together, so every screen watching
/// this provider (Settings screen, and [effectiveThemeModeProvider] for
/// the app root) reacts immediately without a manual reload.
class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() {
    return ref.watch(settingsRepositoryProvider).loadSettings();
  }

  Future<void> setUnitSystem(UnitSystem system) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updateUnitSystem(system);
    state = AsyncData(state.requireValue.copyWith(unitSystem: system));
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updateThemeMode(mode);
    state = AsyncData(state.requireValue.copyWith(themeMode: mode));
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updateNotificationsEnabled(enabled);
    state = AsyncData(state.requireValue.copyWith(notificationsEnabled: enabled));
  }

  Future<void> setSoundsEnabled(bool enabled) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updateSoundsEnabled(enabled);
    state = AsyncData(state.requireValue.copyWith(soundsEnabled: enabled));
  }

  Future<void> setLanguage(AppLanguage language) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updateLanguage(language);
    state = AsyncData(state.requireValue.copyWith(language: language));
  }
}

final settingsControllerProvider = AsyncNotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// Flutter [ThemeMode] derived from persisted settings, consumed directly
/// by [LevelUpApp] in main.dart. Falls back to system while settings are
/// still loading on cold start so there's no flash of the wrong theme.
final effectiveThemeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsControllerProvider);
  return settings.asData?.value.themeMode.toFlutterThemeMode ?? ThemeMode.system;
});
