import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/card.dart';
import '../models/card_model.dart';

abstract class ScanRemoteDataSource {
  Future<CardScanResult> scan(File image);
}

class ScanRemoteDataSourceImpl implements ScanRemoteDataSource {
  final Dio _dio;
  ScanRemoteDataSourceImpl(this._dio);

  @override
  Future<CardScanResult> scan(File image) async {
    try {
      log("called");
      final response = await _dio.post(
        ApiEndpoints.scan,
        data: FormData.fromMap({
          'image': await MultipartFile.fromFile(image.path),
        }),
      );
      log("///////////////////////////////////////");
      log(response.data.toString());
      return CardScanResultModel.fromJson(response.data);
    } on DioException catch (e) {
      log(e.toString());
      throw Failure(
        error: e.response?.data['message']?.toString() ?? e.toString(),
        code: e.response?.statusCode,
      );
    } catch (e) {
      log(e.toString());
      throw Failure(error: e.toString());
    }
  }
}
