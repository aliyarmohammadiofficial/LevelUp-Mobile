import '../../../../core/utils/result.dart';
import '../entities/app_user.dart';

/// Contract for authentication, implemented by [AuthRepositoryImpl] in the
/// data layer. The domain and presentation layers depend only on this
/// interface, never on Supabase/Firebase directly — swapping backends means
/// touching only the data layer.
abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<Result<AppUser>> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Result<AppUser>> logIn({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signInWithGoogle();

  Future<Result<AppUser>> signInWithApple();

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> signOut();
}
