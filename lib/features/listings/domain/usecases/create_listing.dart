import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../collection/domain/entities/collection_item.dart';
import '../entities/listing.dart';
import '../repositories/listings_repository.dart';

class CreateListing {
  final ListingsRepository _repository;
  CreateListing(this._repository);

  Future<Either<Failure, Listing>> call({
    required String catalogCardId,
    required CardCondition condition,
    required double price,
    double fees = 0,
    List<String> markets = const [],
  }) => _repository.createListing(
    catalogCardId: catalogCardId,
    condition: condition,
    price: price,
    fees: fees,
    markets: markets,
  );
}
