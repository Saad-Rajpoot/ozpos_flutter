import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/repository_error_handler.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource dataSource;
  final NetworkInfo networkInfo;

  SettingsRepositoryImpl({required this.dataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<SettingsCategoryEntity>>> getCategories() async {
    return RepositoryErrorHandler.handleOperation<List<SettingsCategoryEntity>>(
      operation: () async => await dataSource.getCategories(),
      networkInfo: networkInfo,
      operationName: 'loading settings categories',
    );
  }
}
