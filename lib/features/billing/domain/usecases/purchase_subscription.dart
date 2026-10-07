import 'package:fpdart/fpdart.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/error/failure.dart';
import '../repositories/billing_repository.dart';

class PurchaseSubscription {
  final BillingRepository _repository;
  PurchaseSubscription(this._repository);

  Future<Either<Failure, void>> call(ProductDetails plan) => _repository.buy(plan);
}
