import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/collection_item.dart';
import '../repositories/collection_repository.dart';

/// Walks every page of `GET /collection` and returns the full list — the
/// endpoint caps `pageSize` at 100, so a large collection needs more than
/// one request.
class GetMyCollection {
  final CollectionRepository _repository;
  GetMyCollection(this._repository);

  Future<Either<Failure, List<CollectionItem>>> call() async {
    final items = <CollectionItem>[];
    var page = 1;
    const pageSize = 100;
    while (true) {
      final either = await _repository.getCollection(
        page: page,
        pageSize: pageSize,
      );
      Failure? failure;
      CollectionPage? result;
      either.match((f) => failure = f, (p) => result = p);
      if (failure != null) return Left(failure!);
      items.addAll(result!.items);
      if (items.length >= result!.total || result!.items.isEmpty) break;
      page++;
    }
    return Right(items);
  }
}
