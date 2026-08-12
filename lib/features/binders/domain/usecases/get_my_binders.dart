import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/binder.dart';
import '../repositories/binder_repository.dart';

class GetMyBinders {
  final BinderRepository _repository;
  GetMyBinders(this._repository);

  Future<Either<Failure, List<Binder>>> call() => _repository.getMyBinders();
}
