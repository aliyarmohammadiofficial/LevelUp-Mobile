import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_settings.dart';

/// Reads/writes [AppSettings] to on-device SharedPreferences. Each field
/// is stored under its own key rather than one blob so a single toggle
/// (e.g. flipping Notifications) doesn't require re-serializing the
/// whole settings object.
class SettingsLocalDataSource {
  static const _keyUnitSystem = 'settings_unit_system';
  static const _keyThemeMode = 'settings_theme_mode';
  static const _keyNotifications = 'settings_notifications_enabled';
  static const _keySounds = 'settings_sounds_enabled';
  static const _keyLanguage = 'settings_language';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = AppSettings.defaults();

    return AppSettings(
      unitSystem: _decodeEnum(
        prefs.getString(_keyUnitSystem),
        UnitSystem.values,
        defaults.unitSystem,
      ),
      themeMode: _decodeEnum(
        prefs.getString(_keyThemeMode),
        AppThemeMode.values,
        defaults.themeMode,
      ),
      notificationsEnabled: prefs.getBool(_keyNotifications) ?? defaults.notificationsEnabled,
      soundsEnabled: prefs.getBool(_keySounds) ?? defaults.soundsEnabled,
      language: _decodeEnum(
        prefs.getString(_keyLanguage),
        AppLanguage.values,
        defaults.language,
      ),
    );
  }

  Future<void> saveUnitSystem(UnitSystem system) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUnitSystem, system.name);
  }

  Future<void> saveThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
  }

  Future<void> saveSoundsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySounds, enabled);
  }

  Future<void> saveLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, language.name);
  }

  T _decodeEnum<T extends Enum>(String? stored, List<T> values, T fallback) {
    if (stored == null) return fallback;
    for (final value in values) {
      if (value.name == stored) return value;
    }
    return fallback;
  }
}
