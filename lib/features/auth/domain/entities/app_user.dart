import 'package:equatable/equatable.dart';

/// Framework-independent user representation used throughout the domain
/// and presentation layers. Data-layer models (Supabase/Firebase user
/// objects) map into this before crossing into the rest of the app.
class AppUser extends Equatable {
  const AppUser({
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

  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    bool? emailVerified,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, fullName, avatarUrl, emailVerified, createdAt];
}
