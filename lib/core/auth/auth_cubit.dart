import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_repository.dart';
import 'auth_state.dart';

/// Manages authentication state transitions (login, logout, session lock).
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthState.unknown()) {
    _initialize();
  }

  final AuthRepository _authRepository;

  Future<void> _initialize() async {
    // For now, auto-authenticate in development to skip login
    final hasSession = await _authRepository.hasActiveSession();
    if (hasSession) {
      emit(AuthState.authenticated());
    } else {
      // Auto-authenticate in development mode (bypass login)
      // In production, this should emit unauthenticated
      emit(AuthState.authenticated());
    }
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _authRepository.login(username: username, password: password);
      emit(AuthState.authenticated());
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          status: AuthStatus.unauthenticated,
          errorMessage: error.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          status: AuthStatus.unauthenticated,
          errorMessage: 'Unable to sign in. Please try again.',
        ),
      );
    }
  }

  Future<void> logout({String? reason}) async {
    await _authRepository.logout();
    emit(AuthState.unauthenticated(message: reason));
  }

  Future<void> handleUnauthorized({String? reason}) async {
    await _authRepository.logout();
    emit(
      AuthState.unauthenticated(
        message: reason ?? 'Session expired. Please sign in again.',
      ),
    );
  }

  /// Locks the current session (e.g., idle timeout or biometric requirement).
  Future<void> lockSession({String? reason}) async {
    emit(
      AuthState.locked(
        message: reason ?? 'Session locked. Re-authentication required.',
      ),
    );
  }

  /// Marks auth state as loading (e.g., verifying biometrics).
  void setLoading(bool value) {
    emit(state.copyWith(isLoading: value));
  }
}
