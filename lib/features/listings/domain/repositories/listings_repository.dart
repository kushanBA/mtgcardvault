import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../collection/domain/entities/collection_item.dart';
import '../entities/listing.dart';

abstract class ListingsRepository {
  Future<Either<Failure, Listing>> createListing({
    required String catalogCardId,
    required CardCondition condition,
    required double price,
    double fees,
    List<String> markets,
  });
}
