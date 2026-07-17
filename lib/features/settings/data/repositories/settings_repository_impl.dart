import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<AppSettings> loadSettings() => _localDataSource.load();

  @override
  Future<void> updateUnitSystem(UnitSystem system) => _localDataSource.saveUnitSystem(system);

  @override
  Future<void> updateThemeMode(AppThemeMode mode) => _localDataSource.saveThemeMode(mode);

  @override
  Future<void> updateNotificationsEnabled(bool enabled) =>
      _localDataSource.saveNotificationsEnabled(enabled);

  @override
  Future<void> updateSoundsEnabled(bool enabled) => _localDataSource.saveSoundsEnabled(enabled);

  @override
  Future<void> updateLanguage(AppLanguage language) => _localDataSource.saveLanguage(language);
}
