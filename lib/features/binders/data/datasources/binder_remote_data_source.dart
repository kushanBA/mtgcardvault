import 'dart:developer';

import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/binder.dart';
import '../models/binder_model.dart';

abstract class BinderRemoteDataSource {
  Future<BinderModel> createBinder(String name, Game game);
  Future<List<BinderModel>> getMyBinders();
  Future<BinderModel> getBinder(String id);
  Future<BinderModel> updateBinder(String id, {String? name, bool? isPublic});
  Future<BinderModel> addCardToBinder(String binderId, String catalogCardId);
  Future<void> removeCardFromPocket(String binderId, int position);
  Future<PublicBindersPageModel> getPublicBinders({Game? game, int page, int pageSize});
}

class BinderRemoteDataSourceImpl implements BinderRemoteDataSource {
  final Dio _dio;
  BinderRemoteDataSourceImpl(this._dio);

  Failure _failureFrom(DioException e) {
    final data = e.response?.data;
    final message = data is Map ? data['message']?.toString() : null;
    return Failure(error: message ?? e.toString(), code: e.response?.statusCode);
  }

  @override
  Future<BinderModel> createBinder(String name, Game game) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.binders,
        data: {'name': name, 'game': game.apiValue},
      );
      return BinderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _failureFrom(e);
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }

  @override
  Future<List<BinderModel>> getMyBinders() async {
    try {
      final response = await _dio.get(ApiEndpoints.binders);
      return (response.data as List).map((b) => BinderModel.fromJson(b as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _failureFrom(e);
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }

  @override
  Future<BinderModel> getBinder(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.binder(id));
      return BinderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _failureFrom(e);
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }

  @override
  Future<BinderModel> updateBinder(String id, {String? name, bool? isPublic}) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.binder(id),
        data: {
          'name': ?name,
          'isPublic': ?isPublic,
        },
      );
      return BinderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _failureFrom(e);
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }

  @override
  Future<BinderModel> addCardToBinder(String binderId, String catalogCardId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.binderPockets(binderId),
        data: {'catalogCardId': catalogCardId},
      );
      return BinderModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _failureFrom(e);
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }

  @override
  Future<void> removeCardFromPocket(String binderId, int position) async {
    try {
      await _dio.delete(ApiEndpoints.binderPocket(binderId, position));
    } on DioException catch (e) {
      throw _failureFrom(e);
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }

  @override
  Future<PublicBindersPageModel> getPublicBinders({Game? game, int page = 1, int pageSize = 20}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.publicBinders,
        queryParameters: {
          if (game != null) 'game': game.apiValue,
          'page': page,
          'pageSize': pageSize,
        },
      );
      return PublicBindersPageModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _failureFrom(e);
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }
}
