import '../errors/failures.dart';

/// Minimal Result/Either type so use cases can return success-or-failure
/// without pulling in a full functional-programming dependency (dartz/fpdart)
/// just for this. Sealed so `switch` is exhaustive at call sites.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = Failure_<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure_<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Failure_<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Failure_<T>(:final failure) => failure,
      };

  R fold<R>(R Function(Failure) onFailure, R Function(T) onSuccess) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Failure_<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Failure_<T> extends Result<T> {
  const Failure_(this.failure);
  final Failure failure;
}
