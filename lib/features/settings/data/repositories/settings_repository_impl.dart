import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource dataSource;
  final NetworkInfo networkInfo;

  SettingsRepositoryImpl({required this.dataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<SettingsCategoryEntity>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final data = await dataSource.getCategories();
        return Right(data);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (_) {
        return Left(ServerFailure(message: 'Unexpected error'));
      }
    } else {
      return const Left(NetworkFailure(message: 'Network error'));
    }
  }
}
