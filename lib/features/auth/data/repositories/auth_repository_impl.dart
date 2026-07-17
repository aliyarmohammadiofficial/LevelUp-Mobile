import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<AppUser?> authStateChanges() {
    return _remote.authStateChanges().map((model) => model?.toEntity());
  }

  @override
  AppUser? get currentUser => _remote.currentUser?.toEntity();

  @override
  Future<Result<AppUser>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remote.signUp(fullName: fullName, email: email, password: password);
      return Result.success(user.toEntity());
    } catch (e) {
      return Result.failure(_mapError(e));
    }
  }

  @override
  Future<Result<AppUser>> logIn({required String email, required String password}) async {
    try {
      final user = await _remote.logIn(email: email, password: password);
      return Result.success(user.toEntity());
    } catch (e) {
      return Result.failure(_mapError(e));
    }
  }

  @override
  Future<Result<AppUser>> signInWithGoogle() async {
    try {
      final user = await _remote.signInWithGoogle();
      return Result.success(user.toEntity());
    } catch (e) {
      return Result.failure(_mapError(e));
    }
  }

  @override
  Future<Result<AppUser>> signInWithApple() async {
    try {
      final user = await _remote.signInWithApple();
      return Result.success(user.toEntity());
    } catch (e) {
      return Result.failure(_mapError(e));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _remote.sendPasswordResetEmail(email);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(_mapError(e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remote.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    if (e is sb.AuthApiException) {
      final code = e.code ?? '';
      final message = e.message.toLowerCase();
      if (code == 'invalid_credentials' || message.contains('invalid login')) {
        return const InvalidCredentialsFailure();
      }
      if (code == 'user_already_exists' || message.contains('already registered')) {
        return const EmailAlreadyInUseFailure();
      }
      if (code == 'weak_password' || message.contains('weak password')) {
        return const WeakPasswordFailure();
      }
      if (message.contains('user not found')) {
        return const UserNotFoundFailure();
      }
      return UnknownAuthFailure(e.message);
    }
    if (e is sb.AuthException) {
      return UnknownAuthFailure(e.message);
    }
    final text = e.toString().toLowerCase();
    if (text.contains('socket') || text.contains('network') || text.contains('timeout')) {
      return const NetworkFailure();
    }
    return UnknownAuthFailure(e.toString());
  }
}
