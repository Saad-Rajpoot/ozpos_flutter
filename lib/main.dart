import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/config/environment_config.dart';
import 'core/di/injection_container.dart' as di;
import 'core/navigation/app_router.dart';
import 'core/observers/sentry_bloc_observer.dart';
import 'theme/app_theme.dart';
import 'features/pos/presentation/bloc/menu_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/combos/presentation/bloc/combo_management_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize BLoC observer for error tracking
  Bloc.observer = SentryBlocObserver();

  // Initialize dependency injection
  await di.init();

  // Set up Flutter error handlers to capture ALL errors
  _setupErrorHandlers();

  // Print environment configuration in debug mode
  EnvironmentConfig.printConfig();

  // Initialize Sentry based on environment configuration
  if (EnvironmentConfig.enableSentry) {
    await SentryFlutter.init((options) {
      options.dsn = EnvironmentConfig.sentryDsn;
      options.environment = EnvironmentConfig.environment;
      options.release = 'ozpos-flutter@${EnvironmentConfig.appVersion}';
      options.tracesSampleRate = EnvironmentConfig.sentrySampleRate;
      options.profilesSampleRate =
          EnvironmentConfig.sentryPerformanceSampleRate;
      options.attachScreenshot = EnvironmentConfig.attachScreenshots;
      options.attachViewHierarchy = EnvironmentConfig.attachViewHierarchy;
      options.debug = EnvironmentConfig.sentryDebug;
      options.maxBreadcrumbs = EnvironmentConfig.maxBreadcrumbs;
      options.autoSessionTrackingInterval =
          EnvironmentConfig.sessionTrackingInterval;
    }, appRunner: () => runApp(const OzposApp()));
  } else {
    // Run app without Sentry in debug mode
    runApp(const OzposApp());
  }
}

class OzposApp extends StatelessWidget {
  const OzposApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MenuBloc>(create: (_) => GetIt.instance<MenuBloc>()),
        BlocProvider<CartBloc>(create: (_) => GetIt.instance<CartBloc>()),
        BlocProvider<ComboManagementBloc>(
          create: (_) => GetIt.instance<ComboManagementBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'OZPOS - Restaurant POS System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.dashboard,
        navigatorObservers: [SentryNavigatorObserver()],
      ),
    );
  }
}

/// Set up comprehensive error handlers to capture all Flutter errors
void _setupErrorHandlers() {
  // Capture Flutter framework errors (like rendering overflow, widget errors)
  FlutterError.onError = (FlutterErrorDetails details) {
    // Let Flutter handle the error first (for debugging)
    FlutterError.presentError(details);

    // Send to Sentry if enabled
    if (EnvironmentConfig.enableSentry) {
      _sendFlutterErrorToSentry(details);
    }
  };

  // Capture platform/async errors that Flutter doesn't catch
  PlatformDispatcher.instance.onError = (error, stack) {
    if (EnvironmentConfig.enableSentry) {
      _sendErrorToSentry(error, stack, 'Platform Error');
    }
    return true;
  };

  // Override debugPrint to capture important debug messages
  if (EnvironmentConfig.enableSentry) {
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      // Call original debugPrint first
      originalDebugPrint?.call(message, wrapWidth: wrapWidth);

      // Check for important error-like debug messages
      if (message != null && _isImportantDebugMessage(message)) {
        _sendDebugMessageToSentry(message);
      }
    };
  }
}

/// Send Flutter framework errors to Sentry
void _sendFlutterErrorToSentry(FlutterErrorDetails details) async {
  try {
    // Extract useful information from the error
    final errorMessage = details.exception.toString();
    final errorType = details.exception.runtimeType.toString();
    final stackTrace = details.stack?.toString() ?? 'No stack trace';
    final context = details.context?.toString() ?? 'No context';
    final library = details.library ?? 'Unknown';

    _sendErrorToSentry(
      details.exception,
      details.stack,
      'Flutter Framework Error',
      extra: {
        'error_type': errorType,
        'library': library,
        'context': context,
        'is_fatal': details.silent == false,
        'flutter_error': true,
      },
    );
  } catch (e) {
    // Don't let error reporting crash the app
    print('Failed to report Flutter error to Sentry: $e');
  }
}

/// Send any error to Sentry via HTTP (bypassing sentry_flutter package issues)
void _sendErrorToSentry(
  dynamic error,
  StackTrace? stackTrace,
  String hint, {
  Map<String, dynamic>? extra,
}) async {
  try {
    const sentryDsn =
        'https://5043c056bceb3ca2e4a92d2e6e2b0235@o4509604948869120.ingest.us.sentry.io/4510112203341824';
    const projectId = '4510112203341824';
    const publicKey = '5043c056bceb3ca2e4a92d2e6e2b0235';

    final url =
        'https://o4509604948869120.ingest.us.sentry.io/api/$projectId/store/';

    // Generate unique event ID
    final eventId = _generateEventId();

    final event = {
      'event_id': eventId,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'platform': 'flutter',
      'logger': 'flutter-auto',
      'level': 'error',
      'server_name': 'ozpos-flutter',
      'release': 'ozpos-flutter@${EnvironmentConfig.appVersion}',
      'environment': EnvironmentConfig.environment,
      'message': {'formatted': '$hint: ${error.toString()}'},
      'exception': {
        'values': [
          {
            'type': error.runtimeType.toString(),
            'value': error.toString(),
            'stacktrace': {'frames': _parseStackTrace(stackTrace)},
          },
        ],
      },
      'tags': {
        'app_name': 'OZPOS',
        'framework': 'flutter',
        'auto_captured': 'true',
        'error_source': hint.toLowerCase().replaceAll(' ', '_'),
      },
      'extra': {
        'hint': hint,
        'timestamp': DateTime.now().toIso8601String(),
        'captured_automatically': true,
        ...?extra,
      },
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Sentry-Auth':
            'Sentry sentry_version=7, sentry_key=$publicKey, sentry_client=ozpos-flutter/1.0.0',
        'User-Agent': 'ozpos-flutter/1.0.0',
      },
      body: json.encode(event),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ Error sent to Sentry: ${error.runtimeType}');
    } else {
      print('❌ Failed to send error to Sentry: HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error reporting to Sentry failed: $e');
  }
}

/// Generate a unique event ID for Sentry
String _generateEventId() {
  final random = Random();
  return List.generate(
    32,
    (index) => random.nextInt(16).toRadixString(16),
  ).join('');
}

/// Parse stack trace into Sentry format
List<Map<String, dynamic>> _parseStackTrace(StackTrace? stackTrace) {
  if (stackTrace == null) return [];

  final lines = stackTrace.toString().split('\n');
  final frames = <Map<String, dynamic>>[];

  for (final line in lines.take(10)) {
    // Limit to 10 frames
    if (line.trim().isEmpty) continue;

    // Try to parse the stack frame
    final match = RegExp(
      r'#\d+\s+(.+?)\s+\((.+?):(\d+):(\d+)\)',
    ).firstMatch(line);
    if (match != null) {
      frames.add({
        'function': match.group(1) ?? 'unknown',
        'filename': match.group(2) ?? 'unknown',
        'lineno': int.tryParse(match.group(3) ?? '0') ?? 0,
        'colno': int.tryParse(match.group(4) ?? '0') ?? 0,
        'in_app': (match.group(2) ?? '').contains('ozpos_flutter'),
      });
    } else {
      // Fallback for unparseable lines
      frames.add({
        'function': line.trim(),
        'filename': 'unknown',
        'lineno': 0,
        'colno': 0,
        'in_app': line.contains('ozpos_flutter'),
      });
    }
  }

  return frames;
}

/// Check if a debug message is important enough to report to Sentry
bool _isImportantDebugMessage(String message) {
  final lowerMessage = message.toLowerCase();

  // Capture BLoC-related errors
  if (lowerMessage.contains('bloc not found') ||
      lowerMessage.contains('bloc error') ||
      lowerMessage.contains('failed to') ||
      lowerMessage.contains('exception') ||
      lowerMessage.contains('error:') ||
      lowerMessage.contains('warning:')) {
    return true;
  }

  // Capture specific OZPOS errors
  if (lowerMessage.contains('cartbloc not found') ||
      lowerMessage.contains('menu') && lowerMessage.contains('error') ||
      lowerMessage.contains('payment') && lowerMessage.contains('failed') ||
      lowerMessage.contains('order') && lowerMessage.contains('failed')) {
    return true;
  }

  return false;
}

/// Send important debug messages to Sentry
void _sendDebugMessageToSentry(String message) async {
  try {
    _sendErrorToSentry(
      Exception('Debug Message: $message'),
      StackTrace.current,
      'Debug Message',
      extra: {
        'original_message': message,
        'message_type': 'debug_print',
        'captured_from': 'debugPrint_override',
      },
    );
  } catch (e) {
    // Silently fail - don't let debug message reporting break anything
  }
}
