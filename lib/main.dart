import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/sentry_config.dart';
import 'core/di/injection_container.dart' as di;
import 'core/navigation/app_router.dart';
import 'core/navigation/navigation_service.dart';
import 'core/utils/sentry_bloc_observer.dart';
import 'core/services/sentry_service.dart';
import 'core/theme/app_theme.dart';
import 'features/menu/presentation/bloc/menu_bloc.dart';
import 'features/combos/presentation/bloc/combo_management_bloc.dart';
import 'features/checkout/presentation/bloc/cart_bloc.dart';
import 'features/checkout/presentation/bloc/checkout_bloc.dart';
import 'features/reservations/presentation/bloc/reservation_management_bloc.dart';
import 'features/reservations/presentation/bloc/reservation_management_event.dart';
import 'features/delivery/presentation/bloc/delivery_bloc.dart';
import 'features/docket/presentation/bloc/docket_management_bloc.dart';
import 'features/printing/presentation/bloc/printing_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize BLoC observer for error tracking
  Bloc.observer = SentryBlocObserver();

  // Initialize AppConfig FIRST (environment-based configuration)
  AppConfig.instance.initialize(
    environment:
        AppEnvironment.development, // Change to production for remote API
  );

  // Initialize dependency injection
  await di.init();

  // Set up Flutter error handlers to capture ALL errors
  _setupErrorHandlers();

  // Print configuration in debug mode
  AppConfig.instance.printConfig();
  SentryConfig.printConfig();

  // Initialize Sentry based on configuration
  if (SentryConfig.enableSentry) {
    // Initialize Sentry and run app
    SentryFlutter.init(
      (options) => _configureSentry(options),
      appRunner: () => runApp(const OzposApp()),
    );
  } else {
    // Run app without Sentry
    runApp(const OzposApp());
  }
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<MenuBloc>(create: (_) => GetIt.instance<MenuBloc>()),
        BlocProvider<CartBloc>(create: (_) => GetIt.instance<CartBloc>()),
        BlocProvider<CheckoutBloc>(
            create: (_) => GetIt.instance<CheckoutBloc>()),
        BlocProvider<ComboManagementBloc>(
          create: (_) => GetIt.instance<ComboManagementBloc>(),
        ),
        BlocProvider<ReservationManagementBloc>(
          create: (_) => GetIt.instance<ReservationManagementBloc>()
            ..add(const LoadReservationsEvent()),
        ),
        BlocProvider<DeliveryBloc>(
          create: (_) => GetIt.instance<DeliveryBloc>(),
        ),
        BlocProvider<DocketManagementBloc>(
          create: (_) => GetIt.instance<DocketManagementBloc>(),
        ),
        BlocProvider<PrintingBloc>(
          create: (_) => GetIt.instance<PrintingBloc>(),
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
    if (SentryConfig.enableSentry) {
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
    if (SentryConfig.enableSentry) {
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
