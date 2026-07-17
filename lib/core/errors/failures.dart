/// Base failure type. Repositories catch raw exceptions from Supabase/
/// Firebase/Dio and translate them into one of these so the presentation
/// layer never depends on a specific backend's exception types.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure() : super('Incorrect email or password.');
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure() : super('An account with this email already exists.');
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure() : super('Password is too weak. Use at least 8 characters.');
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure() : super('No account found with this email.');
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('Network error. Check your connection and try again.');
}

class UnknownAuthFailure extends Failure {
  const UnknownAuthFailure([String? details])
      : super(details ?? 'Something went wrong. Please try again.');
}

class UnknownFailure extends Failure {
  const UnknownFailure([String? details])
      : super(details ?? 'Something went wrong. Please try again.');
}
