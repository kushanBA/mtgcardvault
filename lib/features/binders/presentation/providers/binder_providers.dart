import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/binder_remote_data_source.dart';
import '../../data/repositories/binder_repository_impl.dart';
import '../../domain/entities/binder.dart';
import '../../domain/repositories/binder_repository.dart';
import '../../domain/usecases/add_card_to_binder.dart';
import '../../domain/usecases/create_binder.dart';
import '../../domain/usecases/get_binder.dart';
import '../../domain/usecases/get_my_binders.dart';
import '../../domain/usecases/get_public_binders.dart';
import '../../domain/usecases/remove_card_from_pocket.dart';
import '../../domain/usecases/update_binder.dart';

final binderRemoteDataSourceProvider = Provider<BinderRemoteDataSource>(
  (ref) => BinderRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final binderRepositoryProvider = Provider<BinderRepository>(
  (ref) =>
      BinderRepositoryImpl(remote: ref.watch(binderRemoteDataSourceProvider)),
);

final createBinderUseCaseProvider = Provider(
  (ref) => CreateBinder(ref.watch(binderRepositoryProvider)),
);
final getMyBindersUseCaseProvider = Provider(
  (ref) => GetMyBinders(ref.watch(binderRepositoryProvider)),
);
final getBinderUseCaseProvider = Provider(
  (ref) => GetBinder(ref.watch(binderRepositoryProvider)),
);
final updateBinderUseCaseProvider = Provider(
  (ref) => UpdateBinder(ref.watch(binderRepositoryProvider)),
);
final addCardToBinderUseCaseProvider = Provider(
  (ref) => AddCardToBinder(ref.watch(binderRepositoryProvider)),
);
final removeCardFromPocketUseCaseProvider = Provider(
  (ref) => RemoveCardFromPocket(ref.watch(binderRepositoryProvider)),
);
final getPublicBindersUseCaseProvider = Provider(
  (ref) => GetPublicBinders(ref.watch(binderRepositoryProvider)),
);

final myBindersProvider = FutureProvider.autoDispose<List<Binder>>((ref) async {
  final either = await ref.watch(getMyBindersUseCaseProvider).call();
  return either.match((f) => throw f, (binders) => binders);
});

final binderDetailProvider = FutureProvider.autoDispose.family<Binder, String>((
  ref,
  id,
) async {
  final either = await ref.watch(getBinderUseCaseProvider).call(id);
  return either.match((f) => throw f, (binder) => binder);
});

final publicBindersProvider = FutureProvider.autoDispose<PublicBindersPage>((
  ref,
) async {
  final either = await ref.watch(getPublicBindersUseCaseProvider).call();
  return either.match((f) => throw f, (page) => page);
});
