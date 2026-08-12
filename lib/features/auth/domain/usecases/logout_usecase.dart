import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;
  LogoutUseCase(this._repository);

  Future<Either<Failure, Unit>> call() => _repository.logout();
}
