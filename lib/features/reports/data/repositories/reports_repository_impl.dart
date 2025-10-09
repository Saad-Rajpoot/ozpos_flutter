import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
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
    if (await networkInfo.isConnected) {
      try {
        final reportsData = await reportsDataSource.getReportsData();
        return Right(reportsData);
      } on ServerException {
        return Left(ServerFailure(message: 'Server error'));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }
}
