import 'package:fpdart/fpdart.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/error/failure.dart';
import '../repositories/billing_repository.dart';

class GetSubscriptionPlans {
  final BillingRepository _repository;
  GetSubscriptionPlans(this._repository);

  Future<Either<Failure, List<ProductDetails>>> call(Set<String> productIds) =>
      _repository.getPlans(productIds);
}
