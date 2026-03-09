import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'core/config/app_config.dart';
import 'core/config/sentry_config.dart';
import 'core/di/injection_container.dart' as di;
import 'core/navigation/app_router.dart';
import 'core/navigation/navigation_service.dart';
import 'core/utils/sentry_bloc_observer.dart';
import 'core/services/sentry_service.dart';
import 'core/theme/app_themes.dart';
import 'features/checkout/presentation/bloc/cart_bloc.dart';
import 'features/theme/domain/entities/theme_mode_entity.dart';
import 'features/theme/domain/usecases/get_theme_mode_usecase.dart';
import 'features/theme/domain/usecases/set_theme_mode_usecase.dart';
import 'features/theme/presentation/bloc/theme_bloc.dart';
import 'features/theme/presentation/bloc/theme_state.dart';
import 'features/users/presentation/bloc/user_management_bloc.dart';
import 'core/auth/auth_cubit.dart';
import 'core/auth/auth_state.dart';
import 'core/auth/session_timeout_manager.dart';
import 'core/widgets/user_interaction_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize BLoC observer for error tracking
  Bloc.observer = SentryBlocObserver();

  // Initialize AppConfig FIRST (environment-based configuration)
  const envString =
      String.fromEnvironment('APP_ENV', defaultValue: 'development');
  final env = envString.toLowerCase() == 'production'
      ? AppEnvironment.production
      : AppEnvironment.development;
  AppConfig.instance.initialize(environment: env);

  // Initialize Sentry only if DSN is configured
  // In production, this will throw if DSN is missing (via validatedDsn)
  // In development, Sentry will be disabled if DSN is not provided
  if (SentryConfig.isConfigured) {
    await SentryFlutter.init(
      _configureSentry,
      appRunner: () async {
        await _runApp();
      },
    );
  } else {
    // Development mode: run app without Sentry if DSN not configured
    if (kDebugMode) {
      debugPrint(
          '⚠️  Sentry DSN not configured. Running without error tracking.');
      debugPrint('   To enable: --dart-define=SENTRY_DSN=your_dsn');
    }
    await _runApp();
  }
}

Future<void> _runApp() async {
  try {
    // Set up Flutter error handlers to capture ALL errors
    _setupErrorHandlers();

    // Initialize timezone database for branch timezone (e.g. Australia/Sydney)
    _initializeTimeZones();

    // Initialize Firebase (Realtime Database for order triggers)
    await _initializeFirebase();

    await _initializeDesktopDatabase();
    await _initializeDependencies();

    if (kDebugMode) {
      AppConfig.instance.printConfig();
      SentryConfig.printConfig();
    }

    final authCubit = di.sl<AuthCubit>();
    SessionTimeoutManager.instance.configure(authCubit: authCubit);

    // Load theme before first frame so app starts with persisted theme
    final getThemeMode = di.sl<GetThemeModeUsecase>();
    final initialThemeMode = await getThemeMode();
    final themeBloc = ThemeBloc(
      getThemeMode: getThemeMode,
      setThemeMode: di.sl<SetThemeModeUsecase>(),
      initialMode: initialThemeMode,
    );

    runApp(OzposApp(authCubit: authCubit, themeBloc: themeBloc));
  } catch (error, stackTrace) {
    if (error is BootstrapException) {
      await _reportBootstrapError(
        error.hint,
        error.cause,
        error.originalStackTrace,
      );
      Error.throwWithStackTrace(error, error.originalStackTrace);
    } else {
      await _reportBootstrapError(
        'App bootstrap failed',
        error,
        stackTrace,
      );
      rethrow;
    }
  }
}

void _initializeTimeZones() {
  tz.initializeTimeZones();
}

Future<void> _initializeFirebase() async {
  try {
    const options = FirebaseOptions(
      apiKey: 'AIzaSyCCWtm7U2UTX1xY6BjZqxs161TPdvQUdkw',
      appId: '1:712536179289:web:72fd888e2003d17e7b6748',
      messagingSenderId: '712536179289',
      projectId: 'ozpos-a2b71',
      databaseURL: 'https://ozpos-a2b71-default-rtdb.firebaseio.com',
      storageBucket: 'ozpos-a2b71.firebasestorage.app',
    );

    await Firebase.initializeApp(options: options);
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('Firebase initialization failed: $error');
    }

    if (SentryConfig.isConfigured) {
      await SentryService.reportError(
        error,
        stackTrace,
        hint: 'Firebase initialization failed',
      );
    }
  }
}

Future<void> _initializeDesktopDatabase() async {
  if (kIsWeb || !(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    return;
  }

  try {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } catch (error, stackTrace) {
    throw BootstrapException(
      'Desktop database initialization failed',
      error,
      stackTrace,
      extra: {'platform': Platform.operatingSystem},
    );
  }
}

Future<void> _initializeDependencies() async {
  try {
    await di.init();
  } catch (error, stackTrace) {
    throw BootstrapException(
      'Dependency injection initialization failed',
      error,
      stackTrace,
    );
  }
}

Future<void> _reportBootstrapError(
  String hint,
  Object error,
  StackTrace stackTrace, {
  Map<String, dynamic>? extra,
}) async {
  if (kDebugMode) {
    debugPrint('$hint: $error');
  }

  if (!AppConfig.instance.enableCrashReporting || !SentryConfig.isConfigured) {
    return;
  }

  try {
    await SentryService.reportError(
      error,
      stackTrace,
      hint: hint,
      extra: extra,
    );
  } catch (reportError, _) {
    if (kDebugMode) {
      debugPrint('Sentry reporting failed: $reportError');
    }
  }
}

class BootstrapException implements Exception {
  BootstrapException(
    this.hint,
    this.cause,
    this.originalStackTrace, {
    this.extra,
  });

  final String hint;
  final Object cause;
  final StackTrace originalStackTrace;
  final Map<String, dynamic>? extra;

  @override
  String toString() => 'BootstrapException($hint, $cause)';
}

/// Configure Sentry options for error tracking and performance monitoring
void _configureSentry(SentryFlutterOptions options) {
  // Use validatedDsn which will throw in production if not configured
  options.dsn = SentryConfig.validatedDsn;
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
  const OzposApp({super.key, required this.authCubit, required this.themeBloc});

  final AuthCubit authCubit;
  final ThemeBloc themeBloc;

  @override
  Widget build(BuildContext context) {
    // Only provide globally shared BLoCs here
    // Feature-specific BLoCs are provided at route level for lazy initialization
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<ThemeBloc>.value(value: themeBloc),
        // CartBloc is a singleton registered in DI (see injection_container.dart)
        // It persists across navigation and is accessible throughout the app
        // This is appropriate for a POS system where cart state should persist
        BlocProvider<CartBloc>(create: (_) => GetIt.instance<CartBloc>()),
        // UserManagementBloc is a singleton for real-time user updates
        // This allows the cart dropdown to see new users immediately
        BlocProvider<UserManagementBloc>(
          create: (_) => GetIt.instance<UserManagementBloc>(),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          final manager = SessionTimeoutManager.instance;
          if (state.status == AuthStatus.authenticated) {
            manager.start();
            if (!NavigationService.isCurrentRoute(AppRouter.dashboard)) {
              NavigationService.pushAndClearStack(AppRouter.dashboard);
            }
          } else if (state.status == AuthStatus.unauthenticated) {
            manager.stop();
            if (!NavigationService.isCurrentRoute(AppRouter.login)) {
              NavigationService.pushAndClearStack(
                AppRouter.login,
                arguments:
                    state.message == null ? null : {'message': state.message},
              );
            }
          } else if (state.status == AuthStatus.locked) {
            manager.stop();
            NavigationService.pushAndClearStack(
              AppRouter.login,
              arguments:
                  state.message == null ? null : {'message': state.message},
            );
          }
        },
        child: BlocBuilder<ThemeBloc, ThemeState>(
          buildWhen: (previous, current) =>
              previous != current ||
              (previous is ThemeLoaded && current is ThemeLoaded &&
                  previous.mode != current.mode),
          builder: (context, themeState) {
            final themeMode = themeState is ThemeLoaded
                ? (themeState.mode == AppThemeMode.dark
                    ? ThemeMode.dark
                    : ThemeMode.light)
                : ThemeMode.light;
            return MaterialApp(
              title: 'OZPOS - Restaurant POS System',
              debugShowCheckedModeBanner: false,
              theme: AppThemes.lightTheme,
              darkTheme: AppThemes.darkTheme,
              themeMode: themeMode,
              navigatorKey: NavigationService.navigatorKey,
              onGenerateRoute: AppRouter.generateRoute,
              initialRoute: AppRouter.login,
              navigatorObservers: [SentryNavigatorObserver()],
              builder: (context, child) => UserInteractionListener(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
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

    // Send to Sentry only if configured
    if (SentryConfig.isConfigured) {
      try {
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
      } catch (e) {
        // Silently fail if Sentry is not available
        if (kDebugMode) {
          debugPrint('Failed to report error to Sentry: $e');
        }
      }
    }
  };

  // Capture platform/async errors that Flutter doesn't catch
  PlatformDispatcher.instance.onError = (error, stack) {
    if (SentryConfig.isConfigured) {
      SentryService.reportError(
        error,
        stack,
        hint: 'Platform/Async Error',
        extra: {'error_source': 'platform_dispatcher'},
      );
    }
    return true;
  };
}
