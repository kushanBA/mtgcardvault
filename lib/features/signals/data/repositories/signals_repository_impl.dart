import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/signal.dart';
import '../../domain/repositories/signals_repository.dart';
import '../datasources/signals_remote_data_source.dart';

class SignalsRepositoryImpl implements SignalsRepository {
  final SignalsRemoteDataSource _remote;

  SignalsRepositoryImpl({required SignalsRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, List<Signal>>> getMySignals() async {
    try {
      return Right(await _remote.getMySignals());
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
