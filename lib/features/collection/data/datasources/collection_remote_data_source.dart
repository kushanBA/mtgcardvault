import 'dart:developer';

import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/collection_item.dart';
import '../models/collection_item_model.dart';

abstract class CollectionRemoteDataSource {
  Future<CollectionItemModel> addToCollection(
    String catalogCardId, {
    int quantity,
    CardCondition? condition,
    CardFinish? finish,
  });

  Future<CollectionPageModel> getCollection({int page, int pageSize});
}

class CollectionRemoteDataSourceImpl implements CollectionRemoteDataSource {
  final Dio _dio;
  CollectionRemoteDataSourceImpl(this._dio);

  Failure _failureFrom(DioException e) {
    final data = e.response?.data;
    final message = data is Map ? data['message']?.toString() : null;
    return Failure(
      error: message ?? e.toString(),
      code: e.response?.statusCode,
    );
  }

  @override
  Future<CollectionItemModel> addToCollection(
    String catalogCardId, {
    int quantity = 1,
    CardCondition? condition,
    CardFinish? finish,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.collection,
        data: {
          'catalogCardId': catalogCardId,
          'quantity': quantity,
          if (condition != null) 'condition': condition.apiValue,
          if (finish != null) 'finish': finish.apiValue,
        },
      );
      return CollectionItemModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _failureFrom(e);
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }

  @override
  Future<CollectionPageModel> getCollection({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.collection,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      return CollectionPageModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _failureFrom(e);
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }
}
