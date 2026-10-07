import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class BillingRemoteDataSource {
  Future<void> verifyPurchase(PurchaseDetails purchase);
}

class BillingRemoteDataSourceImpl implements BillingRemoteDataSource {
  final Dio _dio;
  BillingRemoteDataSourceImpl(this._dio);

  @override
  Future<void> verifyPurchase(PurchaseDetails purchase) async {
    try {
      await _dio.post(
        ApiEndpoints.billingVerify,
        data: {
          "platform": Platform.isIOS ? "ios" : "android",
          "productId": purchase.productID,
          "verificationData": purchase.verificationData.serverVerificationData,
        },
      );
    } on DioException catch (e) {
      throw Failure(
        error: e.response?.data['message'] ?? e.message,
        code: e.response?.statusCode,
      );
    } catch (e) {
      throw Failure(error: e.toString());
    }
  }
}
