import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/resource.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/binder.dart';
import '../../domain/usecases/add_card_to_binder.dart';
import '../../domain/usecases/create_binder.dart';
import '../../domain/usecases/get_binder.dart';
import '../../domain/usecases/get_my_binders.dart';
import '../../domain/usecases/get_public_binders.dart';
import '../../domain/usecases/remove_card_from_pocket.dart';
import '../../domain/usecases/update_binder.dart';
import 'binder_event.dart';
import 'binder_state.dart';

class BinderBloc extends Bloc<BinderEvent, BinderState> {
  final GetMyBinders _getMyBinders;
  final GetBinder _getBinder;
  final GetPublicBinders _getPublicBinders;
  final CreateBinder _createBinder;
  final UpdateBinder _updateBinder;
  final AddCardToBinder _addCardToBinder;
  final RemoveCardFromPocket _removeCardFromPocket;

  BinderBloc({
    required GetMyBinders getMyBinders,
    required GetBinder getBinder,
    required GetPublicBinders getPublicBinders,
    required CreateBinder createBinder,
    required UpdateBinder updateBinder,
    required AddCardToBinder addCardToBinder,
    required RemoveCardFromPocket removeCardFromPocket,
  }) : _getMyBinders = getMyBinders,
       _getBinder = getBinder,
       _getPublicBinders = getPublicBinders,
       _createBinder = createBinder,
       _updateBinder = updateBinder,
       _addCardToBinder = addCardToBinder,
       _removeCardFromPocket = removeCardFromPocket,
       super(const BinderState.initial()) {
    on<LoadMyBinders>(_onLoadMyBinders);
    on<LoadBinderDetail>(_onLoadBinderDetail);
    on<LoadPublicBinders>(_onLoadPublicBinders);
    on<LoadCardBinderNames>(_onLoadCardBinderNames);
  }

  Future<void> _onLoadMyBinders(LoadMyBinders event, Emitter<BinderState> emit) async {
    emit(state.copyWith(myBinders: const ResourceLoading()));
    final either = await _getMyBinders();
    emit(
      state.copyWith(
        myBinders: either.match((failure) => ResourceError(failure), (b) => ResourceData(b)),
      ),
    );
  }

  Future<void> _onLoadBinderDetail(LoadBinderDetail event, Emitter<BinderState> emit) async {
    emit(
      state.copyWith(
        binderDetails: {...state.binderDetails, event.id: const ResourceLoading()},
      ),
    );
    final either = await _getBinder(event.id);
    emit(
      state.copyWith(
        binderDetails: {
          ...state.binderDetails,
          event.id: either.match((failure) => ResourceError(failure), (b) => ResourceData(b)),
        },
      ),
    );
  }

  Future<void> _onLoadPublicBinders(LoadPublicBinders event, Emitter<BinderState> emit) async {
    emit(state.copyWith(publicBinders: const ResourceLoading()));
    final either = await _getPublicBinders();
    emit(
      state.copyWith(
        publicBinders: either.match((failure) => ResourceError(failure), (p) => ResourceData(p)),
      ),
    );
  }

  /// Maps each catalog card id to the binder(s) it's currently placed in.
  /// `GET /binders` (used for [BinderState.myBinders]) omits pockets, so this
  /// fetches every binder's full detail to see what's actually in them.
  Future<void> _onLoadCardBinderNames(
    LoadCardBinderNames event,
    Emitter<BinderState> emit,
  ) async {
    emit(state.copyWith(cardBinderNames: const ResourceLoading()));
    List<Binder> myBinders;
    final cached = state.myBinders.valueOrNull;
    if (cached != null) {
      myBinders = cached;
    } else {
      final either = await _getMyBinders();
      final failure = either.match((f) => f, (_) => null);
      if (failure != null) {
        emit(state.copyWith(cardBinderNames: ResourceError(failure)));
        return;
      }
      myBinders = either.match((_) => const <Binder>[], (b) => b);
    }

    final details = await Future.wait(myBinders.map((b) => _getBinder(b.id)));
    final map = <String, List<({String id, String name})>>{};
    for (final either in details) {
      either.match((_) {}, (binder) {
        final seenInThisBinder = <String>{};
        for (final pocket in binder.pockets) {
          final cardId = pocket.catalogCardId;
          if (cardId == null || !seenInThisBinder.add(cardId)) continue;
          (map[cardId] ??= []).add((id: binder.id, name: binder.name));
        }
      });
    }
    emit(state.copyWith(cardBinderNames: ResourceData(map)));
  }

  /// Returns the current binder list, loading it first if it hasn't been
  /// requested yet, or waiting for an in-flight load to settle. Throws the
  /// [Failure] if the load fails.
  Future<List<Binder>> myBindersOrLoad() async {
    var resource = state.myBinders;
    if (resource is ResourceInitial<List<Binder>>) {
      add(const LoadMyBinders());
      resource = await stream
          .map((s) => s.myBinders)
          .firstWhere((r) => r is! ResourceInitial<List<Binder>> && r is! ResourceLoading<List<Binder>>);
    } else if (resource is ResourceLoading<List<Binder>>) {
      resource = await stream
          .map((s) => s.myBinders)
          .firstWhere((r) => r is! ResourceLoading<List<Binder>>);
    }
    return resource.when(
      initial: () => const [],
      loading: () => const [],
      data: (b) => b,
      error: (e, _) => throw e,
    );
  }

  Future<Either<Failure, Binder>> createBinder(String name, Game game) async {
    final either = await _createBinder(name, game);
    either.match((_) {}, (_) => add(const LoadMyBinders()));
    return either;
  }

  /// Updates the binder, then refreshes its detail entry.
  Future<Either<Failure, Binder>> updateBinder(String id, {String? name, bool? isPublic}) async {
    final either = await _updateBinder(id, name: name, isPublic: isPublic);
    either.match((_) {}, (_) => add(LoadBinderDetail(id)));
    return either;
  }

  /// Adds a card to the binder, then refreshes both the binder list and that
  /// binder's detail entry.
  Future<Either<Failure, Binder>> addCardToBinder(String binderId, String catalogCardId) async {
    final either = await _addCardToBinder(binderId, catalogCardId);
    either.match((_) {}, (_) {
      add(const LoadMyBinders());
      add(LoadBinderDetail(binderId));
    });
    return either;
  }

  /// Removes a card from the binder, then refreshes that binder's detail entry.
  Future<Either<Failure, Unit>> removeCardFromPocket(String binderId, int position) async {
    final either = await _removeCardFromPocket(binderId, position);
    either.match((_) {}, (_) => add(LoadBinderDetail(binderId)));
    return either;
  }
}
