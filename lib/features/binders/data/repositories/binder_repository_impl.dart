import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/binder.dart';
import '../../domain/repositories/binder_repository.dart';
import '../datasources/binder_remote_data_source.dart';

class BinderRepositoryImpl implements BinderRepository {
  final BinderRemoteDataSource _remote;

  BinderRepositoryImpl({required BinderRemoteDataSource remote}) : _remote = remote;

  @override
  Future<Either<Failure, Binder>> createBinder(String name, Game game) async {
    try {
      return Right(await _remote.createBinder(name, game));
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<Binder>>> getMyBinders() async {
    try {
      return Right(await _remote.getMyBinders());
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Binder>> getBinder(String id) async {
    try {
      return Right(await _remote.getBinder(id));
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Binder>> updateBinder(String id, {String? name, bool? isPublic}) async {
    try {
      return Right(await _remote.updateBinder(id, name: name, isPublic: isPublic));
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Binder>> addCardToBinder(String binderId, String catalogCardId) async {
    try {
      return Right(await _remote.addCardToBinder(binderId, catalogCardId));
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Unit>> removeCardFromPocket(String binderId, int position) async {
    try {
      await _remote.removeCardFromPocket(binderId, position);
      return const Right(unit);
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, PublicBindersPage>> getPublicBinders({Game? game, int page = 1, int pageSize = 20}) async {
    try {
      return Right(await _remote.getPublicBinders(game: game, page: page, pageSize: pageSize));
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
