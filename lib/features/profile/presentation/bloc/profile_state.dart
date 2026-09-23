import 'package:equatable/equatable.dart';
import '../../../../core/bloc/resource.dart';
import '../../domain/entities/profile.dart';

class ProfileState extends Equatable {
  final Resource<Profile> profile;

  const ProfileState({required this.profile});

  const ProfileState.initial() : profile = const ResourceInitial();

  ProfileState copyWith({Resource<Profile>? profile}) =>
      ProfileState(profile: profile ?? this.profile);

  @override
  List<Object?> get props => [profile];
}
