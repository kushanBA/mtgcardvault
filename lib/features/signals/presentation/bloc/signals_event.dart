import 'package:equatable/equatable.dart';

sealed class SignalsEvent extends Equatable {
  const SignalsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMySignals extends SignalsEvent {
  const LoadMySignals();
}
