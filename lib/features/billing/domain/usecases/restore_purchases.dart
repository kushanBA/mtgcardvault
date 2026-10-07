import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../repositories/billing_repository.dart';

class RestorePurchases {
  final BillingRepository _repository;
  RestorePurchases(this._repository);

  Future<Either<Failure, void>> call() => _repository.restorePurchases();
}
