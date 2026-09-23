import 'package:equatable/equatable.dart';
import '../../../../core/bloc/resource.dart';
import '../../domain/entities/collection_item.dart';

class CollectionState extends Equatable {
  final Resource<List<CollectionItem>> myCollection;

  const CollectionState({required this.myCollection});

  const CollectionState.initial() : myCollection = const ResourceInitial();

  CollectionState copyWith({Resource<List<CollectionItem>>? myCollection}) =>
      CollectionState(myCollection: myCollection ?? this.myCollection);

  @override
  List<Object?> get props => [myCollection];
}
