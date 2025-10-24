import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/addon_management_entities.dart';
import '../../domain/repositories/addon_repository.dart';
import '../datasources/addon_data_source.dart';

/// Addon repository implementation
class AddonRepositoryImpl implements AddonRepository {
  final AddonDataSource addonDataSource;

  AddonRepositoryImpl({
    required this.addonDataSource,
  });

  @override
  Future<Either<Failure, List<AddonCategory>>> getAddonCategories() async {
    try {
      final categories = await addonDataSource.getAddonCategories();
      return Right(categories);
    } on ServerException {
      return Left(ServerFailure(message: 'Server error'));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to load addon categories: $e'));
    }
  }
}
