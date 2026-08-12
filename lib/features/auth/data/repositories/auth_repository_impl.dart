import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final user = await _remote.login(email, password);
      await _local.cacheUser(user);
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, User>> register(
    String email,
    String name,
    String password,
  ) async {
    try {
      final user = await _remote.register(email, password, name);
      await _local.cacheUser(user);
      return Right(user);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await _local.getCachedUser();
      return Right(user);
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      final user = await _local.getCachedUser();
      await _remote.logout(user!.refreshToken);
      await _local.clearCache();

      return const Right(unit);
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }
}
