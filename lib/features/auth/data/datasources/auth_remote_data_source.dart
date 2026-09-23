import 'dart:developer';

import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String name);
  Future<UserModel> loginWithGoogle(String idToken);
  Future<void> logout(String refreshToekn);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.logIn,
        data: {"email": email, "password": password},
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Failure(
        error: e.response!.data['message'],
        code: e.response?.statusCode,
      );
    } catch (e) {
      throw Failure(error: e.toString());
    }
  }

  @override
  Future<UserModel> register(String email, String password, String name) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {"email": email, "password": password, "name": name},
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      log(e.response!.data.toString());
      throw Failure(
        error: e.response!.data['message'].toString(),
        code: e.response?.statusCode,
      );
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }

  @override
  Future<UserModel> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.googleLogin,
        data: {"idToken": idToken},
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Failure(
        error: e.response!.data['message'],
        code: e.response?.statusCode,
      );
    } catch (e) {
      throw Failure(error: e.toString());
    }
  }

  @override
  Future<void> logout(String refreshToekn) async {
    try {
      await _dio.post(
        ApiEndpoints.logout,
        data: {"refreshToken": refreshToekn},
      );
    } on DioException catch (e) {
      log(e.response!.data.toString());
      throw Failure(
        error: e.response!.data['message'].toString(),
        code: e.response?.statusCode,
      );
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }
}
