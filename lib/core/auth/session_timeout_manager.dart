import 'dart:async';

import 'auth_cubit.dart';

/// Manages idle timeout / session locking.
class SessionTimeoutManager {
  SessionTimeoutManager._internal();

  static final SessionTimeoutManager instance =
      SessionTimeoutManager._internal();

  Duration _timeout = const Duration(minutes: 15);
  Timer? _timer;
  AuthCubit? _authCubit;
  bool _enabled = false;

  void configure({
    required AuthCubit authCubit,
    Duration? timeout,
  }) {
    _authCubit = authCubit;
    if (timeout != null) {
      _timeout = timeout;
    }
  }

  void start() {
    if (_authCubit == null) return;
    _enabled = true;
    resetTimer();
  }

  void stop() {
    _enabled = false;
    _timer?.cancel();
  }

  void resetTimer() {
    if (!_enabled) return;
    _timer?.cancel();
    _timer = Timer(_timeout, () {
      _authCubit?.lockSession(
        reason: 'Session locked due to inactivity',
      );
    });
  }
}

