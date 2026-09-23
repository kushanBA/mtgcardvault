import 'dart:developer';

import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../collection/domain/entities/collection_item.dart';
import '../models/listing_model.dart';

abstract class ListingsRemoteDataSource {
  Future<ListingModel> createListing({
    required String catalogCardId,
    required CardCondition condition,
    required double price,
    double fees,
    List<String> markets,
  });
}

class ListingsRemoteDataSourceImpl implements ListingsRemoteDataSource {
  final Dio _dio;
  ListingsRemoteDataSourceImpl(this._dio);

  Failure _failureFrom(DioException e) {
    final data = e.response?.data;
    final message = data is Map ? data['message']?.toString() : null;
    return Failure(
      error: message ?? e.toString(),
      code: e.response?.statusCode,
    );
  }

  @override
  Future<ListingModel> createListing({
    required String catalogCardId,
    required CardCondition condition,
    required double price,
    double fees = 0,
    List<String> markets = const [],
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.listings,
        data: {
          'catalogCardId': catalogCardId,
          'condition': condition.apiValue,
          'price': price,
          'fees': fees,
          'markets': markets,
        },
      );
      return ListingModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _failureFrom(e);
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }
}
