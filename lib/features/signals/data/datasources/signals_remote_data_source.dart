import 'dart:developer';

import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/signal_model.dart';

abstract class SignalsRemoteDataSource {
  Future<List<SignalModel>> getMySignals();
}

class SignalsRemoteDataSourceImpl implements SignalsRemoteDataSource {
  final Dio _dio;
  SignalsRemoteDataSourceImpl(this._dio);

  Failure _failureFrom(DioException e) {
    final data = e.response?.data;
    final message = data is Map ? data['message']?.toString() : null;
    return Failure(
      error: message ?? e.toString(),
      code: e.response?.statusCode,
    );
  }

  @override
  Future<List<SignalModel>> getMySignals() async {
    try {
      final response = await _dio.get(ApiEndpoints.signals);
      final signals = response.data['signals'] as List;
      return signals
          .map((s) => SignalModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _failureFrom(e);
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }
}
