import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<Either<Failure, User>> call(String email, String name, String password) =>
      _repository.register(email, name, password);
}
