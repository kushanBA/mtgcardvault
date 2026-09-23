import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(
    String email,
    String name,
    String password,
  );

  Future<Either<Failure, User>> loginWithGoogle();

  /// Restores a session cached from a previous login, if any.
  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, Unit>> logout();
}
