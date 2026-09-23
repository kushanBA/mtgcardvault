import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/collection_item.dart';

abstract class CollectionRepository {
  Future<Either<Failure, CollectionItem>> addToCollection(
    String catalogCardId, {
    int quantity = 1,
    CardCondition? condition,
    CardFinish? finish,
  });

  Future<Either<Failure, CollectionPage>> getCollection({
    int page = 1,
    int pageSize = 20,
  });
}
