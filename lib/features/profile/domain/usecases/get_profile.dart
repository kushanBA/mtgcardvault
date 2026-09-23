import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository _repository;
  GetProfile(this._repository);

  Future<Either<Failure, Profile>> call() => _repository.getProfile();
}
