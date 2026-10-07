import 'package:fpdart/fpdart.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/error/failure.dart';

abstract class BillingRepository {
  /// Fires whenever the store has an update for a purchase — including ones
  /// started on another device, or ones still pending from before the app
  /// was last killed.
  Stream<List<PurchaseDetails>> get purchaseUpdates;

  Future<Either<Failure, List<ProductDetails>>> getPlans(Set<String> productIds);

  Future<Either<Failure, void>> buy(ProductDetails plan);

  Future<Either<Failure, void>> restorePurchases();

  /// Sends the purchase to the backend to verify with Apple/Google and
  /// update the account's entitlement, then acknowledges the purchase with
  /// the store so it doesn't get auto-refunded.
  Future<Either<Failure, void>> verifyPurchase(PurchaseDetails purchase);
}
