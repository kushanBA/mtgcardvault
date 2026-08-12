import 'dart:io';

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/card.dart';

abstract class ScanRepository {
  Future<Either<Failure, CardScanResult>> scanCard(File image);
}
