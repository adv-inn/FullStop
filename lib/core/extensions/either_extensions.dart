import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Extension methods for Either[Failure, T] to simplify common patterns
extension EitherExtensions<T> on Either<Failure, T> {
  /// Handle the result with callbacks for success and failure
  /// Returns the result of the callback that was executed
  R handle<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return fold(onFailure, onSuccess);
  }

  /// Get the value or a default if it's a failure
  T getOrElse(T defaultValue) {
    return fold((_) => defaultValue, (value) => value);
  }

  /// Get the value or null if it's a failure
  T? getOrNull() {
    return fold((_) => null, (value) => value);
  }

  /// Get the failure or null if it's a success
  Failure? getFailureOrNull() {
    return fold((failure) => failure, (_) => null);
  }

  /// Map only the success value, keeping failure unchanged
  Either<Failure, R> mapSuccess<R>(R Function(T value) mapper) {
    return fold((failure) => Left(failure), (value) => Right(mapper(value)));
  }

  /// Execute a side effect on success without changing the value
  Either<Failure, T> onSuccess(void Function(T value) action) {
    fold((_) {}, action);
    return this;
  }

  /// Execute a side effect on failure without changing the value
  Either<Failure, T> onFailure(void Function(Failure failure) action) {
    fold(action, (_) {});
    return this;
  }

  /// Check if this is a success
  bool get isSuccess => isRight();

  /// Check if this is a failure
  bool get isFailure => isLeft();
}

/// Extension for async operations that return Either
extension FutureEitherExtensions<T> on Future<Either<Failure, T>> {
  /// Handle the async result with callbacks for success and failure
  Future<R> handle<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) async {
    final result = await this;
    return result.handle(onSuccess: onSuccess, onFailure: onFailure);
  }

  /// Get the value or a default if it's a failure
  Future<T> getOrElse(T Function() defaultValue) async {
    final result = await this;
    return result.fold((_) => defaultValue(), (value) => value);
  }

  /// Get the value or null if it's a failure
  Future<T?> getOrNull() async {
    final result = await this;
    return result.getOrNull();
  }

  /// Chain async operations, only executing if previous was successful
  Future<Either<Failure, R>> flatMap<R>(
    Future<Either<Failure, R>> Function(T value) mapper,
  ) async {
    final result = await this;
    return result.fold((failure) => Left(failure), (value) => mapper(value));
  }

  /// Execute a side effect on success
  Future<Either<Failure, T>> onSuccess(void Function(T value) action) async {
    final result = await this;
    return result.onSuccess(action);
  }

  /// Execute a side effect on failure
  Future<Either<Failure, T>> onFailure(
    void Function(Failure failure) action,
  ) async {
    final result = await this;
    return result.onFailure(action);
  }
}
