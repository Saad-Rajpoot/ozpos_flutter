import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../../../features/checkout/data/datasources/checkout_datasource.dart';
import '../../../features/checkout/data/datasources/checkout_local_datasource.dart';
import '../../../features/checkout/data/datasources/checkout_mock_datasource.dart';
import '../../../features/checkout/data/datasources/checkout_remote_datasource.dart';
import '../../../features/checkout/data/repositories/checkout_repository_impl.dart';
import '../../../features/checkout/domain/repositories/checkout_repository.dart';
import '../../../features/checkout/domain/services/payment_processor.dart';
import '../../../features/checkout/domain/services/voucher_validator.dart';
import '../../../features/checkout/domain/usecases/apply_voucher.dart';
import '../../../features/checkout/domain/usecases/book_order.dart';
import '../../../features/checkout/domain/usecases/calculate_totals.dart';
import '../../../features/checkout/domain/usecases/initialize_checkout.dart';
import '../../../features/checkout/domain/usecases/process_payment.dart';
import '../../../features/checkout/presentation/bloc/checkout_bloc.dart';
import '../../services/customer_display_service.dart';
import '../../db/sync_outbox_dao.dart';
import '../../services/imin_hardware_service.dart';

/// Checkout feature module for dependency injection
class CheckoutModule {
  /// Initialize checkout feature dependencies
  static Future<void> init(GetIt sl) async {
    // Data source - handle database availability
    sl.registerLazySingleton<CheckoutDataSource>(() {
      if (sl.isRegistered<Database>()) {
        return CheckoutLocalDataSource(database: sl());
      } else {
        // Fallback for web or when database is not available
        return CheckoutMockDataSource();
      }
    });

    // Remote data source for book-order API
    sl.registerLazySingleton<CheckoutRemoteDataSource>(
      () => CheckoutRemoteDataSource(apiClient: sl()),
    );

    // Domain services
    sl.registerLazySingleton<PaymentProcessor>(
      () => const SimulatedPaymentProcessor(),
    );
    sl.registerLazySingleton<VoucherValidator>(
      () => const InMemoryVoucherValidator(),
    );

    // Repository
    sl.registerLazySingleton<CheckoutRepository>(
      () => CheckoutRepositoryImpl(
        checkoutDataSource: sl(),
        remoteDataSource: sl(),
        networkInfo: sl(),
        sharedPreferences: sl(),
        paymentProcessor: sl(),
        voucherValidator: sl(),
        syncOutboxDao: sl<SyncOutboxDao>(),
        ordersDao: sl(),
      ),
    );

    // Use cases
    sl.registerLazySingleton(() => InitializeCheckoutUseCase());
    sl.registerLazySingleton(() => BookOrderUseCase(repository: sl()));
    sl.registerLazySingleton(() => ProcessPaymentUseCase(repository: sl()));
    sl.registerLazySingleton(() => ApplyVoucherUseCase(repository: sl()));
    sl.registerLazySingleton(() => CalculateTotalsUseCase());

    // BLoC (Factory - new instance each time)
    sl.registerFactory(
      () => CheckoutBloc(
        initializeCheckoutUseCase: sl(),
        bookOrderUseCase: sl(),
        processPaymentUseCase: sl(),
        applyVoucherUseCase: sl(),
        calculateTotalsUseCase: sl(),
        customerDisplayService:
            sl.isRegistered<CustomerDisplayService>() ? sl() : null,
        iminHardwareService:
            sl.isRegistered<IminHardwareService>() ? sl() : null,
      ),
    );
  }
}

