import '../../domain/entities/gamification_stats.dart';
import '../../domain/entities/profile_summary.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/gamification_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._gamificationDataSource);

  final GamificationLocalDataSource _gamificationDataSource;

  @override
  Stream<ProfileSummary> watchProfile({
    String? overrideDisplayName,
    String? overrideEmail,
    String? overrideAvatarUrl,
    DateTime? overrideMemberSince,
  }) async* {
    final stats = await _gamificationDataSource.getStats();
    yield ProfileSummary(
      displayName: overrideDisplayName ?? 'Meowster',
      email: overrideEmail ?? '',
      avatarUrl: overrideAvatarUrl,
      level: stats.level,
      xpIntoLevel: stats.xpIntoLevel,
      xpForNextLevel: stats.xpForNextLevel,
      memberSince: overrideMemberSince,
    );
  }
}
