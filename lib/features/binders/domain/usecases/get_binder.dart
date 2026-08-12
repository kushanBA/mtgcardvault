import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/binder.dart';
import '../repositories/binder_repository.dart';

class GetBinder {
  final BinderRepository _repository;
  GetBinder(this._repository);

  Future<Either<Failure, Binder>> call(String id) => _repository.getBinder(id);
}
