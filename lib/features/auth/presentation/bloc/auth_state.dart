import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

enum AuthStatus {
  /// app just launched, session restore hasn't started yet
  initial,

  /// restoring a persisted session on launch — distinct from [loading] so the
  /// login/register form (which shows its own submit spinner) isn't replaced
  /// by a blank splash while a login/register call is in flight
  restoring,

  /// a login/register call is in flight
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({required this.status, this.user, this.errorMessage});

  const AuthState.initial() : this(status: AuthStatus.initial);

  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, user, errorMessage];
}
