import 'package:fpdart/fpdart.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repositories/billing_repository.dart';
import '../datasources/billing_remote_data_source.dart';

class BillingRepositoryImpl implements BillingRepository {
  final BillingRemoteDataSource _remote;
  final InAppPurchase _iap;

  BillingRepositoryImpl({required BillingRemoteDataSource remote, InAppPurchase? iap})
    : _remote = remote,
      _iap = iap ?? InAppPurchase.instance;

  @override
  Stream<List<PurchaseDetails>> get purchaseUpdates => _iap.purchaseStream;

  @override
  Future<Either<Failure, List<ProductDetails>>> getPlans(Set<String> productIds) async {
    try {
      if (!await _iap.isAvailable()) {
        return Left(Failure(error: 'In-app purchases are not available on this device.'));
      }
      final response = await _iap.queryProductDetails(productIds);
      if (response.error != null) {
        return Left(Failure(error: response.error!.message));
      }
      return Right(response.productDetails);
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> buy(ProductDetails plan) async {
    try {
      await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: plan));
      return const Right(null);
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restorePurchases() async {
    try {
      await _iap.restorePurchases();
      return const Right(null);
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyPurchase(PurchaseDetails purchase) async {
    try {
      await _remote.verifyPurchase(purchase);
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
