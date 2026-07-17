import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../domain/entities/app_user.dart';

/// Data-layer DTO for the authenticated user. Converts a Supabase [sb.User]
/// into the domain's [AppUser]. If a second backend (e.g. Firebase Auth) is
/// ever wired in behind the same [AuthRepository] interface, add a sibling
/// `fromFirebaseUser` factory here rather than touching the domain entity.
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.emailVerified = false,
    this.createdAt,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final bool emailVerified;
  final DateTime? createdAt;

  factory UserModel.fromSupabaseUser(sb.User user, {String? fullNameOverride}) {
    final metadata = user.userMetadata ?? const {};
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: fullNameOverride ?? metadata['full_name'] as String?,
      avatarUrl: metadata['avatar_url'] as String?,
      emailVerified: user.emailConfirmedAt != null,
      createdAt: DateTime.tryParse(user.createdAt),
    );
  }

  AppUser toEntity() => AppUser(
        id: id,
        email: email,
        fullName: fullName,
        avatarUrl: avatarUrl,
        emailVerified: emailVerified,
        createdAt: createdAt,
      );
}
