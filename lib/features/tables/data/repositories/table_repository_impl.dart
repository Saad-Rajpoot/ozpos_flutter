import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/repository_error_handler.dart';
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
    return RepositoryErrorHandler.handleOperation<List<TableEntity>>(
      operation: () async => await tableDataSource.getTables(),
      networkInfo: networkInfo,
      operationName: 'loading tables',
    );
  }

  @override
  Future<Either<Failure, List<TableEntity>>> getMoveAvailableTables() async {
    return RepositoryErrorHandler.handleOperation<List<TableEntity>>(
      operation: () async => await tableDataSource.getMoveAvailableTables(),
      networkInfo: networkInfo,
      operationName: 'loading available tables',
    );
  }
}
