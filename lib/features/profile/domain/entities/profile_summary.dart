import 'package:equatable/equatable.dart';

/// Read-model for the Profile tab's header card (avatar, display name,
/// level badge) — assembled by [ProfileRepository] from the real signed-in
/// Supabase user (name, email, avatar, join date) plus real XP/level
/// tracked from actual app activity (see [GamificationStats]).
class ProfileSummary extends Equatable {
  const ProfileSummary({
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
    required this.memberSince,
  });

  final String displayName;
  final String email;
  final String? avatarUrl;
  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;
  final DateTime? memberSince;

  double get levelProgress =>
      xpForNextLevel == 0 ? 0 : (xpIntoLevel / xpForNextLevel).clamp(0, 1).toDouble();

  @override
  List<Object?> get props =>
      [displayName, email, avatarUrl, level, xpIntoLevel, xpForNextLevel, memberSince];
}
