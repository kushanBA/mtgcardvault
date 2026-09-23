import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/resource.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/collection_item.dart';
import '../../domain/usecases/add_to_collection.dart';
import '../../domain/usecases/get_my_collection.dart';
import 'collection_event.dart';
import 'collection_state.dart';

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final GetMyCollection _getMyCollection;
  final AddToCollection _addToCollection;

  CollectionBloc({
    required GetMyCollection getMyCollection,
    required AddToCollection addToCollection,
  }) : _getMyCollection = getMyCollection,
       _addToCollection = addToCollection,
       super(const CollectionState.initial()) {
    on<LoadMyCollection>(_onLoadMyCollection);
  }

  Future<void> _onLoadMyCollection(
    LoadMyCollection event,
    Emitter<CollectionState> emit,
  ) async {
    emit(state.copyWith(myCollection: const ResourceLoading()));
    final either = await _getMyCollection();
    emit(
      state.copyWith(
        myCollection: either.match(
          (failure) => ResourceError(failure),
          (items) => ResourceData(items),
        ),
      ),
    );
  }

  /// Adds a card to the collection, then refreshes [CollectionState.myCollection].
  Future<Either<Failure, CollectionItem>> addToCollection(
    String catalogCardId, {
    int quantity = 1,
    CardCondition? condition,
    CardFinish? finish,
  }) async {
    final either = await _addToCollection(
      catalogCardId,
      quantity: quantity,
      condition: condition,
      finish: finish,
    );
    either.match((_) {}, (_) => add(const LoadMyCollection()));
    return either;
  }
}
