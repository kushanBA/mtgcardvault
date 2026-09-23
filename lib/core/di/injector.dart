import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/google_sign_in_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/login_with_google_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/binders/data/datasources/binder_remote_data_source.dart';
import '../../features/binders/data/repositories/binder_repository_impl.dart';
import '../../features/binders/domain/repositories/binder_repository.dart';
import '../../features/binders/domain/usecases/add_card_to_binder.dart';
import '../../features/binders/domain/usecases/create_binder.dart';
import '../../features/binders/domain/usecases/get_binder.dart';
import '../../features/binders/domain/usecases/get_my_binders.dart';
import '../../features/binders/domain/usecases/get_public_binders.dart';
import '../../features/binders/domain/usecases/remove_card_from_pocket.dart';
import '../../features/binders/domain/usecases/update_binder.dart';
import '../../features/binders/presentation/bloc/binder_bloc.dart';

import '../../features/collection/data/datasources/collection_remote_data_source.dart';
import '../../features/collection/data/repositories/collection_repository_impl.dart';
import '../../features/collection/domain/repositories/collection_repository.dart';
import '../../features/collection/domain/usecases/add_to_collection.dart';
import '../../features/collection/domain/usecases/get_my_collection.dart';
import '../../features/collection/presentation/bloc/collection_bloc.dart';

import '../../features/listings/data/datasources/listings_remote_data_source.dart';
import '../../features/listings/data/repositories/listings_repository_impl.dart';
import '../../features/listings/domain/repositories/listings_repository.dart';
import '../../features/listings/domain/usecases/create_listing.dart';
import '../../features/listings/presentation/bloc/listings_bloc.dart';

import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_price_alerts.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

import '../../features/scan/data/datasources/scan_remote_data_source.dart';
import '../../features/scan/data/repositories/scan_repository_impl.dart';
import '../../features/scan/domain/repositories/scan_repository.dart';
import '../../features/scan/domain/usecases/scan_card.dart';

import '../../features/signals/data/datasources/signals_remote_data_source.dart';
import '../../features/signals/data/repositories/signals_repository_impl.dart';
import '../../features/signals/domain/repositories/signals_repository.dart';
import '../../features/signals/domain/usecases/get_my_signals.dart';
import '../../features/signals/presentation/bloc/signals_bloc.dart';

import '../pricing/bloc/price_category_bloc.dart';

final sl = GetIt.instance;

/// Wires up every datasource/repository/usecase and Bloc. Called once in
/// `main()` before `runApp`.
///
/// Auth, price category, binders and collection are registered as
/// [GetIt.registerLazySingleton] and provided once at the app root (see
/// `main.dart`) — their state is shared across tabs (e.g. adding a card to a
/// binder from Scan must be reflected on the Binders tab). Profile, signals
/// and listings are only ever read from a single screen each, so they're
/// registered as [GetIt.registerFactory] and scoped to that screen instead.
Future<void> setupInjector() async {
  sl.registerLazySingleton<Dio>(createDio);

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(AuthLocalDataSourceImpl.new);
  sl.registerLazySingleton<GoogleSignInDataSource>(GoogleSignInDataSourceImpl.new);
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), local: sl(), googleSignIn: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(
    () => AuthBloc(
      login: sl(),
      register: sl(),
      logout: sl(),
      getCurrentUser: sl(),
      loginWithGoogle: sl(),
    ),
  );

  // Price category (core, cross-cutting)
  sl.registerLazySingleton(PriceCategoryBloc.new);

  // Binders
  sl.registerLazySingleton<BinderRemoteDataSource>(() => BinderRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<BinderRepository>(() => BinderRepositoryImpl(remote: sl()));
  sl.registerLazySingleton(() => CreateBinder(sl()));
  sl.registerLazySingleton(() => GetMyBinders(sl()));
  sl.registerLazySingleton(() => GetBinder(sl()));
  sl.registerLazySingleton(() => UpdateBinder(sl()));
  sl.registerLazySingleton(() => AddCardToBinder(sl()));
  sl.registerLazySingleton(() => RemoveCardFromPocket(sl()));
  sl.registerLazySingleton(() => GetPublicBinders(sl()));
  sl.registerLazySingleton(
    () => BinderBloc(
      getMyBinders: sl(),
      getBinder: sl(),
      getPublicBinders: sl(),
      createBinder: sl(),
      updateBinder: sl(),
      addCardToBinder: sl(),
      removeCardFromPocket: sl(),
    ),
  );

  // Collection
  sl.registerLazySingleton<CollectionRemoteDataSource>(
    () => CollectionRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CollectionRepository>(() => CollectionRepositoryImpl(remote: sl()));
  sl.registerLazySingleton(() => AddToCollection(sl()));
  sl.registerLazySingleton(() => GetMyCollection(sl()));
  sl.registerLazySingleton(() => CollectionBloc(getMyCollection: sl(), addToCollection: sl()));

  // Profile — screen-scoped
  sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(remote: sl()));
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdatePriceAlerts(sl()));
  sl.registerFactory(() => ProfileBloc(getProfile: sl(), updatePriceAlerts: sl()));

  // Signals — screen-scoped
  sl.registerLazySingleton<SignalsRemoteDataSource>(() => SignalsRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<SignalsRepository>(() => SignalsRepositoryImpl(remote: sl()));
  sl.registerLazySingleton(() => GetMySignals(sl()));
  sl.registerFactory(() => SignalsBloc(getMySignals: sl()));

  // Listings — screen-scoped
  sl.registerLazySingleton<ListingsRemoteDataSource>(() => ListingsRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ListingsRepository>(() => ListingsRepositoryImpl(remote: sl()));
  sl.registerLazySingleton(() => CreateListing(sl()));
  sl.registerFactory(() => ListingsBloc(createListing: sl()));

  // Scan — no reactive state, just a usecase pulled straight from the
  // locator by the screen.
  sl.registerLazySingleton<ScanRemoteDataSource>(() => ScanRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ScanRepository>(() => ScanRepositoryImpl(remote: sl()));
  sl.registerLazySingleton(() => ScanCard(sl()));
}
