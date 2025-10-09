import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/docket_management_entities.dart';
import '../../domain/repositories/docket_repository.dart';
import '../datasources/docket_data_source.dart';

/// Docket repository implementation
class DocketRepositoryImpl implements DocketRepository {
  final DocketDataSource docketDataSource;
  final NetworkInfo networkInfo;

  DocketRepositoryImpl({
    required this.docketDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<DocketEntity>>> getDockets() async {
    if (await networkInfo.isConnected) {
      try {
        final dockets = await docketDataSource.getDockets();
        return Right(dockets);
      } on ServerException {
        return Left(ServerFailure(message: 'Server error'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }
}
