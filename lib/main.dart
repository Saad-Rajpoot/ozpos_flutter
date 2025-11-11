import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/config/app_config.dart';
import 'core/config/sentry_config.dart';
import 'core/di/injection_container.dart' as di;
import 'core/navigation/app_router.dart';
import 'core/navigation/navigation_service.dart';
import 'core/utils/sentry_bloc_observer.dart';
import 'core/services/sentry_service.dart';
import 'core/theme/app_theme.dart';
import 'features/checkout/presentation/bloc/cart_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize BLoC observer for error tracking
  Bloc.observer = SentryBlocObserver();

  // Initialize AppConfig FIRST (environment-based configuration)
  AppConfig.instance.initialize(
    environment:
        AppEnvironment.development, // Change to production for remote API
  );

  // Initialize SQLite for desktop platforms (Windows/Linux/macOS)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize dependency injection
  await di.init();

  // Set up Flutter error handlers to capture ALL errors
  _setupErrorHandlers();

  // Print configuration in debug mode
  AppConfig.instance.printConfig();
  SentryConfig.printConfig();

  await SentryFlutter.init(
    _configureSentry,
    appRunner: () => runApp(const OzposApp()),
  );
}

/// Configure Sentry options for error tracking and performance monitoring
void _configureSentry(SentryFlutterOptions options) {
  options.dsn = SentryConfig.sentryDsn;
  options.environment = AppConfig.instance.environment.name;
  options.release = 'ozpos-flutter@${SentryConfig.appVersion}';
  options.tracesSampleRate = SentryConfig.sentrySampleRate;
  options.profilesSampleRate = SentryConfig.sentryPerformanceSampleRate;
  options.attachScreenshot = SentryConfig.attachScreenshots;
  options.attachViewHierarchy = SentryConfig.attachViewHierarchy;
  options.debug = SentryConfig.sentryDebug;
  options.maxBreadcrumbs = SentryConfig.maxBreadcrumbs;
  options.autoSessionTrackingInterval = SentryConfig.sessionTrackingInterval;
}

class OzposApp extends StatelessWidget {
  const OzposApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Only provide globally shared BLoCs here
    // Feature-specific BLoCs are provided at route level for lazy initialization
    return MultiBlocProvider(
      providers: [
        // CartBloc is a singleton registered in DI (see injection_container.dart)
        // It persists across navigation and is accessible throughout the app
        // This is appropriate for a POS system where cart state should persist
        BlocProvider<CartBloc>(create: (_) => GetIt.instance<CartBloc>()),
      ],
      child: MaterialApp(
        title: 'OZPOS - Restaurant POS System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        navigatorKey: NavigationService.navigatorKey,
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

    // Send to Sentry using the package's built-in method

    Sentry.captureException(
      details.exception,
      stackTrace: details.stack,
      withScope: (scope) {
        scope.setTag('error_type', 'flutter_framework');
        scope.setTag('library', details.library ?? 'unknown');
        scope.setTag('is_fatal', (!details.silent).toString());
        scope.setContexts('flutter_error', {
          'context': details.context?.toString() ?? 'No context',
          'library': details.library ?? 'Unknown',
        });
      },
    );
  };

  // Capture platform/async errors that Flutter doesn't catch
  PlatformDispatcher.instance.onError = (error, stack) {
    SentryService.reportError(
      error,
      stack,
      hint: 'Platform/Async Error',
      extra: {'error_source': 'platform_dispatcher'},
    );
    return true;
  };
}
