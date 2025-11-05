import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
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
    if (await networkInfo.isConnected) {
      try {
        final categories = await addonDataSource.getAddonCategories();
        return Right(categories);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(
            ServerFailure(message: 'Failed to load addon categories: $e'));
      }
    } else {
      return const Left(
          NetworkFailure(message: 'No network connection'));
    }
  }
}
