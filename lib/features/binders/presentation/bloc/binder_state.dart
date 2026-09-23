import 'package:equatable/equatable.dart';
import '../../../../core/bloc/resource.dart';
import '../../domain/entities/binder.dart';

typedef CardBinderNames = Map<String, List<({String id, String name})>>;

class BinderState extends Equatable {
  final Resource<List<Binder>> myBinders;

  /// Keyed by binder id, since more than one detail screen can be open.
  final Map<String, Resource<Binder>> binderDetails;
  final Resource<PublicBindersPage> publicBinders;
  final Resource<CardBinderNames> cardBinderNames;

  const BinderState({
    required this.myBinders,
    required this.binderDetails,
    required this.publicBinders,
    required this.cardBinderNames,
  });

  const BinderState.initial()
    : myBinders = const ResourceInitial(),
      binderDetails = const {},
      publicBinders = const ResourceInitial(),
      cardBinderNames = const ResourceInitial();

  BinderState copyWith({
    Resource<List<Binder>>? myBinders,
    Map<String, Resource<Binder>>? binderDetails,
    Resource<PublicBindersPage>? publicBinders,
    Resource<CardBinderNames>? cardBinderNames,
  }) => BinderState(
    myBinders: myBinders ?? this.myBinders,
    binderDetails: binderDetails ?? this.binderDetails,
    publicBinders: publicBinders ?? this.publicBinders,
    cardBinderNames: cardBinderNames ?? this.cardBinderNames,
  );

  @override
  List<Object?> get props => [myBinders, binderDetails, publicBinders, cardBinderNames];
}
