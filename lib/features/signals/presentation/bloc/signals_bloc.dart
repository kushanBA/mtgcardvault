import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/resource.dart';
import '../../domain/usecases/get_my_signals.dart';
import 'signals_event.dart';
import 'signals_state.dart';

class SignalsBloc extends Bloc<SignalsEvent, SignalsState> {
  final GetMySignals _getMySignals;

  SignalsBloc({required GetMySignals getMySignals})
    : _getMySignals = getMySignals,
      super(const SignalsState.initial()) {
    on<LoadMySignals>(_onLoadMySignals);
  }

  Future<void> _onLoadMySignals(LoadMySignals event, Emitter<SignalsState> emit) async {
    emit(state.copyWith(mySignals: const ResourceLoading()));
    final either = await _getMySignals();
    emit(
      state.copyWith(
        mySignals: either.match((failure) => ResourceError(failure), (s) => ResourceData(s)),
      ),
    );
  }

  /// Reloads and waits for the fetch to settle — for pull-to-refresh.
  Future<void> refresh() {
    add(const LoadMySignals());
    return stream.firstWhere((s) => s.mySignals is! ResourceLoading);
  }
}
