import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../../../features/customer_display/data/datasources/customer_display_data_source.dart';
import '../../../features/customer_display/data/datasources/customer_display_local_datasource.dart';
import '../../../features/customer_display/data/datasources/customer_display_mock_datasource.dart';
import '../../../features/customer_display/data/datasources/customer_display_remote_datasource.dart';
import '../../../features/customer_display/data/repositories/customer_display_repository_impl.dart';
import '../../../features/customer_display/domain/repositories/customer_display_repository.dart';
import '../../../features/customer_display/domain/usecases/get_customer_display.dart';
import '../../../features/customer_display/presentation/bloc/customer_display_bloc.dart';
import '../../config/app_config.dart';

/// Customer Display feature module for dependency injection
class CustomerDisplayModule {
  /// Initialize customer display feature dependencies
  static Future<void> init(GetIt sl) async {
    sl.registerLazySingleton<CustomerDisplayDataSource>(() {
      if (AppConfig.instance.environment == AppEnvironment.development) {
        return CustomerDisplayMockDataSourceImpl();
      }
      if (sl.isRegistered<Database>()) {
        return CustomerDisplayLocalDataSourceImpl(database: sl());
      }
      return CustomerDisplayRemoteDataSourceImpl(apiClient: sl());
    });

    sl.registerLazySingleton<CustomerDisplayRepository>(
      () => CustomerDisplayRepositoryImpl(dataSource: sl()),
    );

    sl.registerLazySingleton(() => GetCustomerDisplay(repository: sl()));

    sl.registerFactory(() => CustomerDisplayBloc(getCustomerDisplay: sl()));
  }
}
