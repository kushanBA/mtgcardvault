import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/google_sign_in_data_source.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _getCurrentUser;
  final LoginWithGoogleUseCase _loginWithGoogle;

  AuthBloc({
    required LoginUseCase login,
    required RegisterUseCase register,
    required LogoutUseCase logout,
    required GetCurrentUserUseCase getCurrentUser,
    required LoginWithGoogleUseCase loginWithGoogle,
  }) : _login = login,
       _register = register,
       _logout = logout,
       _getCurrentUser = getCurrentUser,
       _loginWithGoogle = loginWithGoogle,
       super(const AuthState.initial()) {
    on<AuthRestoreRequested>(_onRestoreRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthGoogleLoginRequested>(_onGoogleLoginRequested);
  }

  Future<void> _onRestoreRequested(
    AuthRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.restoring));
    final result = await _getCurrentUser();
    result.match(
      (failure) => emit(state.copyWith(status: AuthStatus.unauthenticated)),
      (user) => emit(
        user != null
            ? state.copyWith(status: AuthStatus.authenticated, user: user)
            : state.copyWith(status: AuthStatus.unauthenticated),
      ),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    final result = await _login(event.email, event.password);
    result.match(
      (failure) => emit(state.copyWith(status: AuthStatus.error, errorMessage: failure.error)),
      (user) => emit(
        state.copyWith(status: AuthStatus.authenticated, user: user, errorMessage: null),
      ),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    final result = await _register(event.email, event.name, event.password);
    result.match(
      (failure) => emit(state.copyWith(status: AuthStatus.error, errorMessage: failure.error)),
      (user) => emit(
        state.copyWith(status: AuthStatus.authenticated, user: user, errorMessage: null),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final result = await _loginWithGoogle();
      result.match(
        (failure) => emit(state.copyWith(status: AuthStatus.error, errorMessage: failure.error)),
        (user) => emit(
          state.copyWith(status: AuthStatus.authenticated, user: user, errorMessage: null),
        ),
      );
    } on GoogleSignInCancelled {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }
}
