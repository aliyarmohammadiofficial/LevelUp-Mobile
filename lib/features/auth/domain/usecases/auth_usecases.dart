import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  const SignUpUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<AppUser>> call({
    required String fullName,
    required String email,
    required String password,
  }) {
    if (fullName.trim().isEmpty) {
      return Future.value(const Result.failure(UnknownAuthFailure('Please enter your name.')));
    }
    return _repository.signUp(fullName: fullName.trim(), email: email.trim(), password: password);
  }
}

class LogInUseCase {
  const LogInUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<AppUser>> call({required String email, required String password}) {
    return _repository.logIn(email: email.trim(), password: password);
  }
}

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<AppUser>> call() => _repository.signInWithGoogle();
}

class SignInWithAppleUseCase {
  const SignInWithAppleUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<AppUser>> call() => _repository.signInWithApple();
}

class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call(String email) => _repository.sendPasswordResetEmail(email.trim());
}

class SignOutUseCase {
  const SignOutUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.signOut();
}
