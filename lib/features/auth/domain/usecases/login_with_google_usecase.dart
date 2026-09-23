import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogleUseCase {
  final AuthRepository _repository;
  LoginWithGoogleUseCase(this._repository);

  Future<Either<Failure, User>> call() => _repository.loginWithGoogle();
}
