import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Base usecase interface with parameters
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base usecase interface without parameters
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// No parameters marker class
class NoParams {
  const NoParams();
}
