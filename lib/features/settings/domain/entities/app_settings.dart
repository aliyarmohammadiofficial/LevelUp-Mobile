import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Measurement system used across Nutrition/Progress/Workout screens
/// (weights, distances, body measurements).
enum UnitSystem { metric, imperial }

extension UnitSystemLabel on UnitSystem {
  String get label => switch (this) {
        UnitSystem.metric => 'Metric (kg, cm)',
        UnitSystem.imperial => 'Imperial (lb, ft)',
      };
}

/// App-level theme preference. Maps 1:1 onto [ThemeMode] but kept as its
/// own enum so the settings layer doesn't leak a Flutter type into the
/// domain entity below.
enum AppThemeMode { light, dark, system }

extension AppThemeModeMapping on AppThemeMode {
  String get label => switch (this) {
        AppThemeMode.light => 'Light',
        AppThemeMode.dark => 'Dark',
        AppThemeMode.system => 'System',
      };

  ThemeMode get toFlutterThemeMode => switch (this) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      };
}

/// Supported in-app languages. LevelUp's copy is English-first today;
/// Persian is offered here as a stored preference for the upcoming RTL
/// localization pass — selecting it does not yet retranslate the UI.
enum AppLanguage { english, persian }

extension AppLanguageLabel on AppLanguage {
  String get label => switch (this) {
        AppLanguage.english => 'English',
        AppLanguage.persian => 'فارسی (Persian)',
      };
}

/// User-configurable app preferences, persisted locally (SharedPreferences)
/// and read by [SettingsRepository]. Matches the reference "Settings"
/// screen's rows: Units, Theme, Notifications, Sounds, Language.
class AppSettings extends Equatable {
  const AppSettings({
    required this.unitSystem,
    required this.themeMode,
    required this.notificationsEnabled,
    required this.soundsEnabled,
    required this.language,
  });

  factory AppSettings.defaults() => const AppSettings(
        unitSystem: UnitSystem.metric,
        themeMode: AppThemeMode.light,
        notificationsEnabled: true,
        soundsEnabled: true,
        language: AppLanguage.english,
      );

  final UnitSystem unitSystem;
  final AppThemeMode themeMode;
  final bool notificationsEnabled;
  final bool soundsEnabled;
  final AppLanguage language;

  AppSettings copyWith({
    UnitSystem? unitSystem,
    AppThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? soundsEnabled,
    AppLanguage? language,
  }) {
    return AppSettings(
      unitSystem: unitSystem ?? this.unitSystem,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props =>
      [unitSystem, themeMode, notificationsEnabled, soundsEnabled, language];
}
