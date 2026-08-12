import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/scan_remote_data_source.dart';
import '../../data/repositories/scan_repository_impl.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../domain/usecases/scan_card.dart';

final scanRemoteDataSourceProvider = Provider<ScanRemoteDataSource>(
  (ref) => ScanRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final scanRepositoryProvider = Provider<ScanRepository>(
  (ref) => ScanRepositoryImpl(remote: ref.watch(scanRemoteDataSourceProvider)),
);

final scanCardUseCaseProvider = Provider(
  (ref) => ScanCard(ref.watch(scanRepositoryProvider)),
);
