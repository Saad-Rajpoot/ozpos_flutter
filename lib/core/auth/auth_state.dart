import 'package:equatable/equatable.dart';

/// Represents the authentication status of the current session.
enum AuthStatus {
  /// The app is checking for an existing session.
  unknown,

  /// User is not authenticated and must sign in.
  unauthenticated,

  /// User is authenticated and can access protected routes.
  authenticated,

  /// Session is locked (e.g., idle timeout). Re-authentication required.
  locked,
}

/// Immutable authentication state shared across the app.
class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.isLoading = false,
    this.message,
    this.errorMessage,
  });

  /// Current auth status.
  final AuthStatus status;

  /// Whether an auth operation (login/logout) is in progress.
  final bool isLoading;

  /// Informational message (e.g., session expired).
  final String? message;

  /// Error message for failed auth attempts.
  final String? errorMessage;

  /// Initial unknown state while session check runs.
  factory AuthState.unknown() =>
      const AuthState(status: AuthStatus.unknown, isLoading: true);

  /// Authenticated state.
  factory AuthState.authenticated({String? message}) => AuthState(
        status: AuthStatus.authenticated,
        message: message,
      );

  /// Unauthenticated state.
  factory AuthState.unauthenticated({String? message}) => AuthState(
        status: AuthStatus.unauthenticated,
        message: message,
      );

  /// Locked state (idle timeout, biometric step-up, etc.).
  factory AuthState.locked({String? message}) => AuthState(
        status: AuthStatus.locked,
        message: message,
      );

  /// Loading state (e.g., signing in).
  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? message,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;

  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  bool get isLocked => status == AuthStatus.locked;

  bool get isUnknown => status == AuthStatus.unknown;

  @override
  List<Object?> get props => [status, isLoading, message, errorMessage];
}
