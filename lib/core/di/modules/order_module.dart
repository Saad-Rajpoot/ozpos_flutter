import 'package:get_it/get_it.dart';

import '../../../features/orders/data/datasources/orders_data_source.dart';
import '../../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../../features/orders/domain/repositories/orders_repository.dart';
import '../../../features/orders/domain/usecases/get_orders.dart';
import '../../../features/orders/presentation/bloc/orders_management_bloc.dart';
import '../../db/orders_dao.dart';

/// Order feature module for dependency injection
class OrderModule {
  /// Initialize order feature dependencies
  static Future<void> init(GetIt sl) async {
    // Order Management screen uses history API (GET /api/pos/orders/history) in all environments
    sl.registerLazySingleton<OrdersDataSource>(
      () => OrdersRemoteDataSourceImpl(apiClient: sl()),
    );

    // Repository (remote + Drift-backed local cache)
    sl.registerLazySingleton<OrdersRepository>(
      () => OrdersRepositoryImpl(
        ordersDataSource: sl<OrdersDataSource>(),
        networkInfo: sl(),
        ordersDao: sl<OrdersDao>(),
      ),
    );

    // Use cases
    sl.registerLazySingleton(() => GetOrders(sl()));

    // BLoC (Factory - new instance each time)
    sl.registerFactory(() => OrdersManagementBloc(getOrders: sl()));
  }
}

