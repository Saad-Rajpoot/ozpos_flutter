import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/customer_display_entity.dart';
import '../../domain/repositories/customer_display_repository.dart';
import '../datasources/customer_display_data_source.dart';

class CustomerDisplayRepositoryImpl implements CustomerDisplayRepository {
  final CustomerDisplayDataSource dataSource;

  CustomerDisplayRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, CustomerDisplayEntity>> getDisplayContent() async {
    try {
      final display = await dataSource.getContent();
      return Right(display);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Unexpected error loading customer display: $e'),
      );
    }
  }
}
