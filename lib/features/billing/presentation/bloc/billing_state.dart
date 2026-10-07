import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/bloc/resource.dart';

enum SubscriptionPurchaseStatus { idle, pending, success, error }

class BillingState extends Equatable {
  final Resource<List<ProductDetails>> plans;
  final SubscriptionPurchaseStatus purchaseStatus;
  final String? errorMessage;

  const BillingState({required this.plans, required this.purchaseStatus, this.errorMessage});

  const BillingState.initial()
    : plans = const ResourceInitial(),
      purchaseStatus = SubscriptionPurchaseStatus.idle,
      errorMessage = null;

  BillingState copyWith({
    Resource<List<ProductDetails>>? plans,
    SubscriptionPurchaseStatus? purchaseStatus,
    String? errorMessage,
  }) => BillingState(
    plans: plans ?? this.plans,
    purchaseStatus: purchaseStatus ?? this.purchaseStatus,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [plans, purchaseStatus, errorMessage];
}
