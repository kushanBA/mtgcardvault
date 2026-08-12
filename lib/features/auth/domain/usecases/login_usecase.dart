import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<Either<Failure, User>> call(String email, String password) =>
      _repository.login(email, password);
}
