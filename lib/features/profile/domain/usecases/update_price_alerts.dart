import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdatePriceAlerts {
  final ProfileRepository _repository;
  UpdatePriceAlerts(this._repository);

  Future<Either<Failure, Profile>> call(bool enabled) =>
      _repository.updatePriceAlerts(enabled);
}
