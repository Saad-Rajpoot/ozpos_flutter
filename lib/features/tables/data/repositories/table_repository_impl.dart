import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/repositories/table_repository.dart';
import '../datasources/table_data_source.dart';

/// Table repository implementation
class TableRepositoryImpl implements TableRepository {
  final TableDataSource tableDataSource;
  final NetworkInfo networkInfo;

  TableRepositoryImpl({
    required this.tableDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<TableEntity>>> getTables() async {
    if (await networkInfo.isConnected) {
      try {
        final tables = await tableDataSource.getTables();
        return Right(tables);
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
            ServerFailure(message: 'Unexpected error loading tables: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No network connection'));
    }
  }

  @override
  Future<Either<Failure, List<TableEntity>>> getMoveAvailableTables() async {
    if (await networkInfo.isConnected) {
      try {
        final tables = await tableDataSource.getMoveAvailableTables();
        return Right(tables);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(
            message: 'Unexpected error loading available tables: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No network connection'));
    }
  }
}
