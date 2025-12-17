import 'package:get_it/get_it.dart';

import '../../../features/orders/data/datasources/orders_data_source.dart';
import '../../../features/orders/data/datasources/orders_mock_datasource.dart';
import '../../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../../features/orders/domain/repositories/orders_repository.dart';
import '../../../features/orders/domain/usecases/get_orders.dart';
import '../../../features/orders/presentation/bloc/orders_management_bloc.dart';
import '../../config/app_config.dart';

/// Order feature module for dependency injection
class OrderModule {
  /// Initialize order feature dependencies
  static Future<void> init(GetIt sl) async {
    // Environment-based data source selection
    sl.registerLazySingleton<OrdersDataSource>(() {
      if (AppConfig.instance.environment == AppEnvironment.development) {
        // Use mock data source for development
        return OrdersMockDataSourceImpl();
      } else {
        // Use remote data source for production
        return OrdersRemoteDataSourceImpl(apiClient: sl());
      }
    });

    // Repository
    sl.registerLazySingleton<OrdersRepository>(
      () => OrdersRepositoryImpl(ordersDataSource: sl(), networkInfo: sl()),
    );

    // Use cases
    sl.registerLazySingleton(() => GetOrders(sl()));

    // BLoC (Factory - new instance each time)
    sl.registerFactory(() => OrdersManagementBloc(getOrders: sl()));
  }
}

