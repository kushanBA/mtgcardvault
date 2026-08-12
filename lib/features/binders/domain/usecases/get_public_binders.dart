import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/binder.dart';
import '../repositories/binder_repository.dart';

class GetPublicBinders {
  final BinderRepository _repository;
  GetPublicBinders(this._repository);

  Future<Either<Failure, PublicBindersPage>> call({Game? game, int page = 1, int pageSize = 20}) =>
      _repository.getPublicBinders(game: game, page: page, pageSize: pageSize);
}
