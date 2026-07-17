import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import 'auth_providers.dart';

/// Shared state shape for all three auth forms (login, signup, forgot
/// password): tracks submission state and the last failure so the UI can
/// show an inline error without re-deriving it from a raw exception.
class AuthFormState {
  const AuthFormState({this.isSubmitting = false, this.failure, this.succeeded = false});

  final bool isSubmitting;
  final Failure? failure;
  final bool succeeded;

  AuthFormState copyWith({bool? isSubmitting, Failure? failure, bool? succeeded, bool clearFailure = false}) {
    return AuthFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: clearFailure ? null : (failure ?? this.failure),
      succeeded: succeeded ?? this.succeeded,
    );
  }
}

class LogInController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<void> submit({required String email, required String password}) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    final result = await ref.read(logInUseCaseProvider).call(email: email, password: password);
    state = result.fold(
      (failure) => state.copyWith(isSubmitting: false, failure: failure),
      (_) => state.copyWith(isSubmitting: false, succeeded: true),
    );
  }

  Future<void> submitGoogle() async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    final result = await ref.read(signInWithGoogleUseCaseProvider).call();
    state = result.fold(
      (failure) => state.copyWith(isSubmitting: false, failure: failure),
      (_) => state.copyWith(isSubmitting: false, succeeded: true),
    );
  }

  Future<void> submitApple() async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    final result = await ref.read(signInWithAppleUseCaseProvider).call();
    state = result.fold(
      (failure) => state.copyWith(isSubmitting: false, failure: failure),
      (_) => state.copyWith(isSubmitting: false, succeeded: true),
    );
  }
}

class SignUpController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<void> submit({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    final result = await ref
        .read(signUpUseCaseProvider)
        .call(fullName: fullName, email: email, password: password);
    state = result.fold(
      (failure) => state.copyWith(isSubmitting: false, failure: failure),
      (_) => state.copyWith(isSubmitting: false, succeeded: true),
    );
  }
}

class ForgotPasswordController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<void> submit(String email) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    final result = await ref.read(sendPasswordResetUseCaseProvider).call(email);
    state = result.fold(
      (failure) => state.copyWith(isSubmitting: false, failure: failure),
      (_) => state.copyWith(isSubmitting: false, succeeded: true),
    );
  }
}

final logInControllerProvider = NotifierProvider<LogInController, AuthFormState>(LogInController.new);
final signUpControllerProvider = NotifierProvider<SignUpController, AuthFormState>(SignUpController.new);
final forgotPasswordControllerProvider =
    NotifierProvider<ForgotPasswordController, AuthFormState>(ForgotPasswordController.new);
