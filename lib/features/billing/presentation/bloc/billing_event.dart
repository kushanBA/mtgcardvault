import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

sealed class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlans extends BillingEvent {
  final Set<String> productIds;
  const LoadPlans(this.productIds);

  @override
  List<Object?> get props => [productIds];
}

class PurchaseRequested extends BillingEvent {
  final ProductDetails plan;
  const PurchaseRequested(this.plan);

  @override
  List<Object?> get props => [plan];
}

class RestoreRequested extends BillingEvent {
  const RestoreRequested();
}

/// Internal — fed by the store's purchase stream, not dispatched by the UI.
class PurchaseUpdatesReceived extends BillingEvent {
  final List<PurchaseDetails> purchases;
  const PurchaseUpdatesReceived(this.purchases);

  @override
  List<Object?> get props => [purchases];
}
