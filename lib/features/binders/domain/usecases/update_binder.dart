import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/binder.dart';
import '../repositories/binder_repository.dart';

class UpdateBinder {
  final BinderRepository _repository;
  UpdateBinder(this._repository);

  Future<Either<Failure, Binder>> call(String id, {String? name, bool? isPublic}) =>
      _repository.updateBinder(id, name: name, isPublic: isPublic);
}
