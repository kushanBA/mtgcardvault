import 'package:fpdart/fpdart.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/error/failure.dart';
import '../repositories/billing_repository.dart';

class VerifyPurchase {
  final BillingRepository _repository;
  VerifyPurchase(this._repository);

  Future<Either<Failure, void>> call(PurchaseDetails purchase) =>
      _repository.verifyPurchase(purchase);
}
