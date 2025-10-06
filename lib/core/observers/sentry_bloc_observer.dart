import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../services/sentry_service.dart';

/// BLoC observer that automatically reports errors and events to Sentry
class SentryBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    
    // Track BLoC creation for debugging
    SentryService.addBreadcrumb(
      message: 'BLoC Created: ${bloc.runtimeType}',
      category: 'bloc',
      level: SentryLevel.debug,
      data: {
        'bloc_type': bloc.runtimeType.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }


  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    
    // Report BLoC errors to Sentry with context
    SentryService.reportError(
      error,
      stackTrace,
      hint: 'BLoC Error in ${bloc.runtimeType}',
      extra: {
        'bloc_type': bloc.runtimeType.toString(),
        'current_state': bloc.state.runtimeType.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Also add as breadcrumb for context
    SentryService.addBreadcrumb(
      message: 'BLoC Error: ${bloc.runtimeType} - ${error.toString()}',
      category: 'bloc_error',
      level: SentryLevel.error,
      data: {
        'bloc_type': bloc.runtimeType.toString(),
        'error_type': error.runtimeType.toString(),
        'error_message': error.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    
    // Track BLoC disposal
    SentryService.addBreadcrumb(
      message: 'BLoC Closed: ${bloc.runtimeType}',
      category: 'bloc',
      level: SentryLevel.debug,
      data: {
        'bloc_type': bloc.runtimeType.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

}
