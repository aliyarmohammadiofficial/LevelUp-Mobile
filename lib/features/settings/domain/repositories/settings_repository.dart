import '../entities/app_settings.dart';

/// Contract for reading/writing user preferences. Backed today by
/// SharedPreferences via [SettingsRepositoryImpl] — swappable for a
/// Supabase-synced implementation later without changing call sites.
abstract class SettingsRepository {
  Future<AppSettings> loadSettings();
  Future<void> updateUnitSystem(UnitSystem system);
  Future<void> updateThemeMode(AppThemeMode mode);
  Future<void> updateNotificationsEnabled(bool enabled);
  Future<void> updateSoundsEnabled(bool enabled);
  Future<void> updateLanguage(AppLanguage language);
}
