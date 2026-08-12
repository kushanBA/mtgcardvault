import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../state/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _getCurrentUser;

  AuthNotifier({
    required LoginUseCase login,
    required RegisterUseCase register,
    required LogoutUseCase logout,
    required GetCurrentUserUseCase getCurrentUser,
  })  : _login = login,
        _register = register,
        _logout = logout,
        _getCurrentUser = getCurrentUser,
        super(const AuthState.initial()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    state = state.copyWith(status: AuthStatus.restoring);
    final result = await _getCurrentUser();
    result.match(
      (failure) => state = state.copyWith(status: AuthStatus.unauthenticated),
      (user) => state = user != null
          ? state.copyWith(status: AuthStatus.authenticated, user: user)
          : state.copyWith(status: AuthStatus.unauthenticated),
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _login(email, password);
    result.match(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.error),
      (user) => state = state.copyWith(status: AuthStatus.authenticated, user: user, errorMessage: null),
    );
  }

  Future<void> register(String email, String name, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _register(email, name, password);
    result.match(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.error),
      (user) => state = state.copyWith(status: AuthStatus.authenticated, user: user, errorMessage: null),
    );
  }

  Future<void> logout() async {
    await _logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
