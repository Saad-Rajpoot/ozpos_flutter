import 'package:get_it/get_it.dart';

import '../../../features/tables/data/datasources/table_data_source.dart';
import '../../../features/tables/data/datasources/table_mock_datasource.dart';
import '../../../features/tables/data/datasources/table_remote_datasource.dart';
import '../../../features/tables/data/repositories/table_repository_impl.dart';
import '../../../features/tables/domain/repositories/table_repository.dart';
import '../../../features/tables/domain/usecases/get_available_tables.dart';
import '../../../features/tables/domain/usecases/get_tables.dart';
import '../../../features/tables/presentation/bloc/table_management_bloc.dart';
import '../../config/app_config.dart';

/// Table feature module for dependency injection
class TableModule {
  /// Initialize table feature dependencies
  static Future<void> init(GetIt sl) async {
    // Environment-based data source selection for main tables
    sl.registerLazySingleton<TableDataSource>(() {
      if (AppConfig.instance.environment == AppEnvironment.development) {
        // Use mock data source for development
        return TableMockDataSourceImpl();
      } else {
        // Use remote data source for production
        return TableRemoteDataSourceImpl(apiClient: sl());
      }
    });

    // Repositories
    sl.registerLazySingleton<TableRepository>(
      () => TableRepositoryImpl(tableDataSource: sl(), networkInfo: sl()),
    );

    // Use cases
    sl.registerLazySingleton(() => GetTables(sl()));
    sl.registerLazySingleton(() => GetMoveAvailableTables(sl()));

    // BLoCs (Factory - new instance each time)
    sl.registerFactory(
      () => TableManagementBloc(getTables: sl(), getMoveAvailableTables: sl()),
    );
  }
}

