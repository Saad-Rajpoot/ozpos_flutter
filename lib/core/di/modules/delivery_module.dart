import 'package:get_it/get_it.dart';

import '../../../features/delivery/data/datasources/delivery_data_source.dart';
import '../../../features/delivery/data/datasources/delivery_mock_datasource.dart';
import '../../../features/delivery/data/datasources/delivery_remote_datasource.dart';
import '../../../features/delivery/data/repositories/delivery_repository_impl.dart';
import '../../../features/delivery/domain/repositories/delivery_repository.dart';
import '../../../features/delivery/domain/usecases/get_delivery_data.dart';
import '../../../features/delivery/presentation/bloc/delivery_bloc.dart';
import '../../config/app_config.dart';

/// Delivery feature module for dependency injection
class DeliveryModule {
  /// Initialize delivery feature dependencies
  static Future<void> init(GetIt sl) async {
    // Environment-based data source selection
    sl.registerLazySingleton<DeliveryDataSource>(() {
      if (AppConfig.instance.environment == AppEnvironment.development) {
        // Use local data source for development (JSON files)
        return DeliveryMockDataSourceImpl();
      } else {
        // Use remote data source for production
        return DeliveryRemoteDataSourceImpl(apiClient: sl());
      }
    });

    // Repository
    sl.registerLazySingleton<DeliveryRepository>(
      () => DeliveryRepositoryImpl(deliveryDataSource: sl(), networkInfo: sl()),
    );

    // Use cases
    sl.registerLazySingleton(() => GetDeliveryData(sl()));

    // BLoC (Factory - new instance each time)
    sl.registerFactory(() => DeliveryBloc(getDeliveryData: sl()));
  }
}

