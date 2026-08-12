import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../notifiers/auth_notifier.dart';
import '../state/auth_state.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSourceImpl(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
  ),
);

final loginUseCaseProvider = Provider((ref) => LoginUseCase(ref.watch(authRepositoryProvider)));
final registerUseCaseProvider = Provider((ref) => RegisterUseCase(ref.watch(authRepositoryProvider)));
final logoutUseCaseProvider = Provider((ref) => LogoutUseCase(ref.watch(authRepositoryProvider)));
final getCurrentUserUseCaseProvider =
    Provider((ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)));

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    login: ref.watch(loginUseCaseProvider),
    register: ref.watch(registerUseCaseProvider),
    logout: ref.watch(logoutUseCaseProvider),
    getCurrentUser: ref.watch(getCurrentUserUseCaseProvider),
  ),
);
