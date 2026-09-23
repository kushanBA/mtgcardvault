import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/collection_item.dart';
import '../repositories/collection_repository.dart';

class GetCollection {
  final CollectionRepository _repository;
  GetCollection(this._repository);

  Future<Either<Failure, CollectionPage>> call({
    int page = 1,
    int pageSize = 20,
  }) => _repository.getCollection(page: page, pageSize: pageSize);
}
