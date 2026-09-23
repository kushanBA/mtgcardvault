import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/collection_item.dart';
import '../repositories/collection_repository.dart';

class AddToCollection {
  final CollectionRepository _repository;
  AddToCollection(this._repository);

  Future<Either<Failure, CollectionItem>> call(
    String catalogCardId, {
    int quantity = 1,
    CardCondition? condition,
    CardFinish? finish,
  }) => _repository.addToCollection(
    catalogCardId,
    quantity: quantity,
    condition: condition,
    finish: finish,
  );
}
