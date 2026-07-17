import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/gamification_local_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile_summary.dart';
import '../../domain/repositories/profile_repository.dart';

final gamificationLocalDataSourceProvider = Provider((ref) => GamificationLocalDataSource());

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(gamificationLocalDataSourceProvider));
});

/// Merges the signed-in [AppUser] (name/email/avatar/join date, from
/// Supabase) with real XP/level totalled from actual app activity.
final profileSummaryProvider = StreamProvider<ProfileSummary>((ref) {
  final authUser = ref.watch(authStateProvider).asData?.value;
  return ref.watch(profileRepositoryProvider).watchProfile(
        overrideDisplayName: authUser?.fullName,
        overrideEmail: authUser?.email,
        overrideAvatarUrl: authUser?.avatarUrl,
        overrideMemberSince: authUser?.createdAt,
      );
});
