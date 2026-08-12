import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../repositories/binder_repository.dart';

class RemoveCardFromPocket {
  final BinderRepository _repository;
  RemoveCardFromPocket(this._repository);

  Future<Either<Failure, Unit>> call(String binderId, int position) =>
      _repository.removeCardFromPocket(binderId, position);
}
