import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/bloc/resource.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../domain/usecases/get_subscription_plans.dart';
import '../../domain/usecases/purchase_subscription.dart';
import '../../domain/usecases/restore_purchases.dart';
import '../../domain/usecases/verify_purchase.dart';
import '../../domain/usecases/watch_purchase_updates.dart';
import 'billing_event.dart';
import 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetSubscriptionPlans _getSubscriptionPlans;
  final PurchaseSubscription _purchaseSubscription;
  final RestorePurchases _restorePurchases;
  final VerifyPurchase _verifyPurchase;
  final ProfileBloc _profileBloc;
  StreamSubscription<List<PurchaseDetails>>? _purchaseUpdatesSubscription;

  BillingBloc({
    required GetSubscriptionPlans getSubscriptionPlans,
    required PurchaseSubscription purchaseSubscription,
    required RestorePurchases restorePurchases,
    required VerifyPurchase verifyPurchase,
    required WatchPurchaseUpdates watchPurchaseUpdates,
    required ProfileBloc profileBloc,
  }) : _getSubscriptionPlans = getSubscriptionPlans,
       _purchaseSubscription = purchaseSubscription,
       _restorePurchases = restorePurchases,
       _verifyPurchase = verifyPurchase,
       _profileBloc = profileBloc,
       super(const BillingState.initial()) {
    on<LoadPlans>(_onLoadPlans);
    on<PurchaseRequested>(_onPurchaseRequested);
    on<RestoreRequested>(_onRestoreRequested);
    on<PurchaseUpdatesReceived>(_onPurchaseUpdatesReceived);

    // Apple requires listening from app start, not just while a purchase
    // screen is open, so interrupted or externally-completed transactions
    // (e.g. family sharing, or the app being killed mid-purchase) still get
    // delivered and completed.
    _purchaseUpdatesSubscription = watchPurchaseUpdates().listen(
      (purchases) => add(PurchaseUpdatesReceived(purchases)),
    );
  }

  Future<void> _onLoadPlans(LoadPlans event, Emitter<BillingState> emit) async {
    emit(state.copyWith(plans: const ResourceLoading()));
    final either = await _getSubscriptionPlans(event.productIds);
    emit(
      state.copyWith(
        plans: either.match((failure) => ResourceError(failure), (p) => ResourceData(p)),
      ),
    );
  }

  Future<void> _onPurchaseRequested(
    PurchaseRequested event,
    Emitter<BillingState> emit,
  ) async {
    emit(state.copyWith(purchaseStatus: SubscriptionPurchaseStatus.pending, errorMessage: null));
    final either = await _purchaseSubscription(event.plan);
    either.match(
      (failure) => emit(
        state.copyWith(purchaseStatus: SubscriptionPurchaseStatus.error, errorMessage: failure.error),
      ),
      (_) {},
    );
  }

  Future<void> _onRestoreRequested(
    RestoreRequested event,
    Emitter<BillingState> emit,
  ) async {
    emit(state.copyWith(purchaseStatus: SubscriptionPurchaseStatus.pending, errorMessage: null));
    final either = await _restorePurchases();
    either.match(
      (failure) => emit(
        state.copyWith(purchaseStatus: SubscriptionPurchaseStatus.error, errorMessage: failure.error),
      ),
      (_) {},
    );
  }

  Future<void> _onPurchaseUpdatesReceived(
    PurchaseUpdatesReceived event,
    Emitter<BillingState> emit,
  ) async {
    for (final purchase in event.purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          emit(state.copyWith(purchaseStatus: SubscriptionPurchaseStatus.pending));
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final either = await _verifyPurchase(purchase);
          either.match(
            (failure) => emit(
              state.copyWith(purchaseStatus: SubscriptionPurchaseStatus.error, errorMessage: failure.error),
            ),
            (_) {
              emit(state.copyWith(purchaseStatus: SubscriptionPurchaseStatus.success));
              _profileBloc.add(const LoadProfile());
            },
          );
        case PurchaseStatus.error:
          emit(
            state.copyWith(
              purchaseStatus: SubscriptionPurchaseStatus.error,
              errorMessage: purchase.error?.message ?? 'Purchase failed.',
            ),
          );
        case PurchaseStatus.canceled:
          emit(state.copyWith(purchaseStatus: SubscriptionPurchaseStatus.idle));
      }
    }
  }

  @override
  Future<void> close() {
    _purchaseUpdatesSubscription?.cancel();
    return super.close();
  }
}
