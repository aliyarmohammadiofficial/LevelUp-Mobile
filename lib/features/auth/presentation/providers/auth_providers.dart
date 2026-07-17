import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

final supabaseClientProvider = Provider<sb.SupabaseClient>((ref) {
  return sb.Supabase.instance.client;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final signUpUseCaseProvider = Provider((ref) => SignUpUseCase(ref.watch(authRepositoryProvider)));
final logInUseCaseProvider = Provider((ref) => LogInUseCase(ref.watch(authRepositoryProvider)));
final signInWithGoogleUseCaseProvider =
    Provider((ref) => SignInWithGoogleUseCase(ref.watch(authRepositoryProvider)));
final signInWithAppleUseCaseProvider =
    Provider((ref) => SignInWithAppleUseCase(ref.watch(authRepositoryProvider)));
final sendPasswordResetUseCaseProvider =
    Provider((ref) => SendPasswordResetUseCase(ref.watch(authRepositoryProvider)));
final signOutUseCaseProvider = Provider((ref) => SignOutUseCase(ref.watch(authRepositoryProvider)));

/// Live stream of the current auth state — the router listens to this to
/// decide whether to show the auth flow or the authenticated app shell.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
