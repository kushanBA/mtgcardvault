import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/bloc/resource.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_price_alerts.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile _getProfile;
  final UpdatePriceAlerts _updatePriceAlerts;

  ProfileBloc({
    required GetProfile getProfile,
    required UpdatePriceAlerts updatePriceAlerts,
  }) : _getProfile = getProfile,
       _updatePriceAlerts = updatePriceAlerts,
       super(const ProfileState.initial()) {
    on<LoadProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(profile: const ResourceLoading()));
    final either = await _getProfile();
    emit(
      state.copyWith(
        profile: either.match((failure) => ResourceError(failure), (p) => ResourceData(p)),
      ),
    );
  }

  /// Updates the price-alerts flag, then refreshes [ProfileState.profile].
  Future<Either<Failure, Profile>> updatePriceAlerts(bool enabled) async {
    final either = await _updatePriceAlerts(enabled);
    either.match((_) {}, (_) => add(const LoadProfile()));
    return either;
  }
}
