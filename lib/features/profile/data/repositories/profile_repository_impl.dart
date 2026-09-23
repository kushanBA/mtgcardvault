import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;

  ProfileRepositoryImpl({required ProfileRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    try {
      return Right(await _remote.getProfile());
    } on Failure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Profile>> updatePriceAlerts(bool enabled) async {
    try {
      return Right(await _remote.updatePriceAlerts(enabled));
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
