import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failure.dart';
import '../../../collection/domain/entities/collection_item.dart';
import '../../domain/entities/listing.dart';
import '../../domain/usecases/create_listing.dart';
import 'listings_event.dart';
import 'listings_state.dart';

class ListingsBloc extends Bloc<ListingsEvent, ListingsState> {
  final CreateListing _createListing;

  ListingsBloc({required CreateListing createListing})
    : _createListing = createListing,
      super(const ListingsState.initial());

  Future<Either<Failure, Listing>> createListing({
    required String catalogCardId,
    required CardCondition condition,
    required double price,
    double fees = 0,
    List<String> markets = const [],
  }) => _createListing(
    catalogCardId: catalogCardId,
    condition: condition,
    price: price,
    fees: fees,
    markets: markets,
  );
}
