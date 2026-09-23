import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/signal.dart';

abstract class SignalsRepository {
  Future<Either<Failure, List<Signal>>> getMySignals();
}
