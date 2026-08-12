import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/binder.dart';

abstract class BinderRepository {
  Future<Either<Failure, Binder>> createBinder(String name, Game game);

  /// Own binders, without pockets — call [getBinder] for the full detail.
  Future<Either<Failure, List<Binder>>> getMyBinders();

  Future<Either<Failure, Binder>> getBinder(String id);

  Future<Either<Failure, Binder>> updateBinder(String id, {String? name, bool? isPublic});

  /// Fills the lowest-numbered empty pocket — the caller doesn't choose which.
  Future<Either<Failure, Binder>> addCardToBinder(String binderId, String catalogCardId);

  Future<Either<Failure, Unit>> removeCardFromPocket(String binderId, int position);

  Future<Either<Failure, PublicBindersPage>> getPublicBinders({
    Game? game,
    int page = 1,
    int pageSize = 20,
  });
}
