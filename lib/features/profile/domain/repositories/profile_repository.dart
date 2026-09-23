import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile();
  Future<Either<Failure, Profile>> updatePriceAlerts(bool enabled);
}
