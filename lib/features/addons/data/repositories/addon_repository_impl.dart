import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/repository_error_handler.dart';
import '../../domain/entities/addon_management_entities.dart';
import '../../domain/repositories/addon_repository.dart';
import '../datasources/addon_data_source.dart';

/// Addon repository implementation
class AddonRepositoryImpl implements AddonRepository {
  final AddonDataSource addonDataSource;
  final NetworkInfo networkInfo;

  AddonRepositoryImpl({
    required this.addonDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AddonCategory>>> getAddonCategories() async {
    return RepositoryErrorHandler.handleOperation<List<AddonCategory>>(
      operation: () async => await addonDataSource.getAddonCategories(),
      networkInfo: networkInfo,
      operationName: 'loading addon categories',
    );
  }
}
