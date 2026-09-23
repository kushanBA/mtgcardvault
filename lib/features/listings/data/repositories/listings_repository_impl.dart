import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../collection/domain/entities/collection_item.dart';
import '../../domain/entities/listing.dart';
import '../../domain/repositories/listings_repository.dart';
import '../datasources/listings_remote_data_source.dart';

class ListingsRepositoryImpl implements ListingsRepository {
  final ListingsRemoteDataSource _remote;

  ListingsRepositoryImpl({required ListingsRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, Listing>> createListing({
    required String catalogCardId,
    required CardCondition condition,
    required double price,
    double fees = 0,
    List<String> markets = const [],
  }) async {
    try {
      return Right(
        await _remote.createListing(
          catalogCardId: catalogCardId,
          condition: condition,
          price: price,
          fees: fees,
          markets: markets,
        ),
      );
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
