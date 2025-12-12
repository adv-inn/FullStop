import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/auth_repository.dart';
import '../usecase.dart';

class AuthenticateUser extends UseCaseNoParams<String> {
  final AuthRepository repository;

  AuthenticateUser(this.repository);

  @override
  Future<Either<Failure, String>> call() async {
    return await repository.authenticate();
  }
}
