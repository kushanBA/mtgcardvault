import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/binder.dart';
import '../repositories/binder_repository.dart';

class AddCardToBinder {
  final BinderRepository _repository;
  AddCardToBinder(this._repository);

  Future<Either<Failure, Binder>> call(String binderId, String catalogCardId) =>
      _repository.addCardToBinder(binderId, catalogCardId);
}
