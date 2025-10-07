import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/config/environment_config.dart';
import 'core/di/injection_container.dart' as di;
import 'core/navigation/app_router.dart';
import 'core/navigation/navigation_service.dart';
import 'core/utils/sentry_bloc_observer.dart';
import 'core/services/sentry_service.dart';
import 'core/theme/app_theme.dart';
import 'features/menu/presentation/bloc/menu_bloc.dart';
import 'features/combos/presentation/bloc/combo_management_bloc.dart';
import 'features/checkout/presentation/bloc/cart_bloc.dart';

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
    if (EnvironmentConfig.enableSentry) {
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
    }
  };

  // Capture platform/async errors that Flutter doesn't catch
  PlatformDispatcher.instance.onError = (error, stack) {
    if (EnvironmentConfig.enableSentry) {
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
