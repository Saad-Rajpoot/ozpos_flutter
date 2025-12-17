import 'package:get_it/get_it.dart';

import '../../../features/reports/data/datasources/reports_data_source.dart';
import '../../../features/reports/data/datasources/reports_mock_datasource.dart';
import '../../../features/reports/data/datasources/reports_remote_datasource.dart';
import '../../../features/reports/data/repositories/reports_repository_impl.dart';
import '../../../features/reports/domain/repositories/reports_repository.dart';
import '../../../features/reports/domain/usecases/get_reports_data.dart';
import '../../../features/reports/presentation/bloc/reports_bloc.dart';
import '../../config/app_config.dart';

/// Report feature module for dependency injection
class ReportModule {
  /// Initialize report feature dependencies
  static Future<void> init(GetIt sl) async {
    // Environment-based data source selection
    sl.registerLazySingleton<ReportsDataSource>(() {
      if (AppConfig.instance.environment == AppEnvironment.development) {
        // Use mock data source for development
        return ReportsMockDataSourceImpl();
      } else {
        // Use remote data source for production
        return ReportsRemoteDataSourceImpl(apiClient: sl());
      }
    });

    // Repository
    sl.registerLazySingleton<ReportsRepository>(
      () => ReportsRepositoryImpl(reportsDataSource: sl(), networkInfo: sl()),
    );

    // Use cases
    sl.registerLazySingleton(() => GetReportsData(sl()));

    // BLoC (Factory - new instance each time)
    sl.registerFactory(() => ReportsBloc(getReportsData: sl()));
  }
}

