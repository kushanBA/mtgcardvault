import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/signal.dart';
import '../repositories/signals_repository.dart';

class GetMySignals {
  final SignalsRepository _repository;
  GetMySignals(this._repository);

  Future<Either<Failure, List<Signal>>> call() => _repository.getMySignals();
}
