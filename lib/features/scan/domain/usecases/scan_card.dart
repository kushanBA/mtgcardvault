import 'dart:io';

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/card.dart';
import '../repositories/scan_repository.dart';

class ScanCard {
  final ScanRepository _repository;
  ScanCard(this._repository);

  Future<Either<Failure, CardScanResult>> call(File image) => _repository.scanCard(image);
}
