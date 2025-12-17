import 'package:get_it/get_it.dart';

import '../../../features/users/data/datasources/user_data_source.dart';
import '../../../features/users/data/datasources/user_mock_datasource.dart';
import '../../../features/users/data/datasources/user_remote_datasource.dart';
import '../../../features/users/data/repositories/user_repository_impl.dart';
import '../../../features/users/domain/repositories/user_repository.dart';
import '../../../features/users/domain/usecases/get_users.dart';
import '../../../features/users/domain/usecases/create_user.dart';
import '../../../features/users/domain/usecases/update_user.dart';
import '../../../features/users/presentation/bloc/user_management_bloc.dart';
import '../../../features/users/presentation/bloc/user_management_event.dart';
import '../../config/app_config.dart';

/// User feature module for dependency injection
class UserModule {
  /// Initialize user feature dependencies
  static Future<void> init(GetIt sl) async {
    // Environment-based data source selection
    sl.registerLazySingleton<UserDataSource>(() {
      if (AppConfig.instance.environment == AppEnvironment.development) {
        // Use mock data source for development
        return UserMockDataSourceImpl();
      } else {
        // Use remote data source for production
        return UserRemoteDataSourceImpl(apiClient: sl());
      }
    });

    // Repositories
    sl.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(
        userDataSource: sl(),
        networkInfo: sl(),
      ),
    );

    // Use cases
    sl.registerLazySingleton(() => GetUsers(sl()));
    sl.registerLazySingleton(() => CreateUser(sl()));
    sl.registerLazySingleton(() => UpdateUser(sl()));

    // BLoC (Singleton - shared across app for real-time updates)
    // This allows the cart dropdown to see new users immediately
    sl.registerLazySingleton(
      () => UserManagementBloc(
        getUsers: sl(),
        createUser: sl(),
        updateUser: sl(),
      )..add(const LoadUsersEvent()), // Load users on initialization
    );
  }
}
