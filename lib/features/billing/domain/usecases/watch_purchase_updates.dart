import 'package:in_app_purchase/in_app_purchase.dart';
import '../repositories/billing_repository.dart';

class WatchPurchaseUpdates {
  final BillingRepository _repository;
  WatchPurchaseUpdates(this._repository);

  Stream<List<PurchaseDetails>> call() => _repository.purchaseUpdates;
}
