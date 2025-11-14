import 'package:flutter/widgets.dart';

import '../auth/session_timeout_manager.dart';

/// Captures user interactions to reset the idle timeout timer.
class UserInteractionListener extends StatelessWidget {
  const UserInteractionListener({super.key, required this.child});

  final Widget child;

  void _registerInteraction() {
    SessionTimeoutManager.instance.resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _registerInteraction(),
      onPointerSignal: (_) => _registerInteraction(),
      child: child,
    );
  }
}

