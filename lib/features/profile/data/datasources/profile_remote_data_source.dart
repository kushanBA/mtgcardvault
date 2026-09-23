import 'dart:developer';

import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updatePriceAlerts(bool enabled);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;
  ProfileRemoteDataSourceImpl(this._dio);

  Failure _failureFrom(DioException e) {
    final data = e.response?.data;
    final message = data is Map ? data['message']?.toString() : null;
    return Failure(
      error: message ?? e.toString(),
      code: e.response?.statusCode,
    );
  }

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.profile);
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _failureFrom(e);
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }

  @override
  Future<ProfileModel> updatePriceAlerts(bool enabled) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.profile,
        data: {'priceAlertsEnabled': enabled},
      );
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _failureFrom(e);
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }
}
