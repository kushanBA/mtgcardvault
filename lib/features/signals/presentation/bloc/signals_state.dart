import 'package:equatable/equatable.dart';
import '../../../../core/bloc/resource.dart';
import '../../domain/entities/signal.dart';

class SignalsState extends Equatable {
  final Resource<List<Signal>> mySignals;

  const SignalsState({required this.mySignals});

  const SignalsState.initial() : mySignals = const ResourceInitial();

  SignalsState copyWith({Resource<List<Signal>>? mySignals}) =>
      SignalsState(mySignals: mySignals ?? this.mySignals);

  @override
  List<Object?> get props => [mySignals];
}
