import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/card.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/scan_remote_data_source.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ScanRemoteDataSource _remote;

  ScanRepositoryImpl({required ScanRemoteDataSource remote}) : _remote = remote;

  @override
  Future<Either<Failure, CardScanResult>> scanCard(File image) async {
    try {
      // final bytes = await rootBundle.load('assets/cards/card-back.png');
      // final img = File('${Directory.systemTemp.path}/card-back.png')
      //   ..writeAsBytesSync(bytes.buffer.asUint8List(), flush: true);
      final result = await _remote.scan(image);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    }
  }
}
