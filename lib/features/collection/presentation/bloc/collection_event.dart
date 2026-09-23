import 'package:equatable/equatable.dart';

sealed class CollectionEvent extends Equatable {
  const CollectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyCollection extends CollectionEvent {
  const LoadMyCollection();
}
