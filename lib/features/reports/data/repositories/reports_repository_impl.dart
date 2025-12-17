import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/repository_error_handler.dart';
import '../../domain/entities/reports_entities.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_data_source.dart';

/// Reports repository implementation
class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsDataSource reportsDataSource;
  final NetworkInfo networkInfo;

  ReportsRepositoryImpl({
    required this.reportsDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ReportsData>> getReportsData() async {
    return RepositoryErrorHandler.handleOperation<ReportsData>(
      operation: () async => await reportsDataSource.getReportsData(),
      networkInfo: networkInfo,
      operationName: 'loading reports data',
    );
  }
}
