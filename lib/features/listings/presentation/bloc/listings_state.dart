import 'package:equatable/equatable.dart';
import '../../../../core/bloc/resource.dart';
import '../../domain/entities/listing.dart';

class ListingsState extends Equatable {
  final Resource<Listing> lastListing;

  const ListingsState({required this.lastListing});

  const ListingsState.initial() : lastListing = const ResourceInitial();

  @override
  List<Object?> get props => [lastListing];
}
