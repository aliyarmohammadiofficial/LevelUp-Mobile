import '../entities/profile_summary.dart';

/// Contract for the Profile tab's header data. [ProfileRepositoryImpl]
/// merges the signed-in Supabase [AppUser] (name/email/avatar/join date)
/// with real XP/level totalled from actual app activity in
/// [GamificationLocalDataSource] — same cross-feature aggregation pattern
/// as [DashboardRepository].
abstract class ProfileRepository {
  Stream<ProfileSummary> watchProfile({
    String? overrideDisplayName,
    String? overrideEmail,
    String? overrideAvatarUrl,
    DateTime? overrideMemberSince,
  });
}
