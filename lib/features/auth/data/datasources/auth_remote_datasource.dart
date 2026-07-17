import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../models/user_model.dart';

/// Thin wrapper around the Supabase Auth SDK. This is the only file that
/// should ever import `supabase_flutter` for auth — everything above it
/// (repository, use cases, UI) talks to [UserModel] / [AppUser] instead.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final sb.SupabaseClient _client;

  Stream<UserModel?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((state) {
      final user = state.session?.user;
      return user == null ? null : UserModel.fromSupabaseUser(user);
    });
  }

  UserModel? get currentUser {
    final user = _client.auth.currentUser;
    return user == null ? null : UserModel.fromSupabaseUser(user);
  }

  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
    final user = response.user;
    if (user == null) {
      throw const sb.AuthException('Sign up failed. Please try again.');
    }
    return UserModel.fromSupabaseUser(user, fullNameOverride: fullName);
  }

  Future<UserModel> logIn({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(email: email, password: password);
    final user = response.user;
    if (user == null) {
      throw const sb.AuthException('Login failed. Please try again.');
    }
    return UserModel.fromSupabaseUser(user);
  }

  Future<UserModel> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      sb.OAuthProvider.google,
      redirectTo: 'io.levelup.app://login-callback',
    );
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const sb.AuthException('Google sign-in was cancelled or failed.');
    }
    return UserModel.fromSupabaseUser(user);
  }

  Future<UserModel> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      sb.OAuthProvider.apple,
      redirectTo: 'io.levelup.app://login-callback',
    );
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const sb.AuthException('Apple sign-in was cancelled or failed.');
    }
    return UserModel.fromSupabaseUser(user);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() => _client.auth.signOut();
}
