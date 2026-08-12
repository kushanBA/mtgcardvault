import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/binder.dart';
import '../repositories/binder_repository.dart';

class CreateBinder {
  final BinderRepository _repository;
  CreateBinder(this._repository);

  Future<Either<Failure, Binder>> call(String name, Game game) => _repository.createBinder(name, game);
}
