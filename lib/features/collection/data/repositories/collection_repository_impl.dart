import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/collection_item.dart';
import '../../domain/repositories/collection_repository.dart';
import '../datasources/collection_remote_data_source.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final CollectionRemoteDataSource _remote;

  CollectionRepositoryImpl({required CollectionRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, CollectionItem>> addToCollection(
    String catalogCardId, {
    int quantity = 1,
    CardCondition? condition,
    CardFinish? finish,
  }) async {
    try {
      return Right(
        await _remote.addToCollection(
          catalogCardId,
          quantity: quantity,
          condition: condition,
          finish: finish,
        ),
      );
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, CollectionPage>> getCollection({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      return Right(await _remote.getCollection(page: page, pageSize: pageSize));
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
