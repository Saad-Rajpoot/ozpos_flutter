import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/docket_management_entities.dart';

/// Docket repository interface
abstract class DocketRepository {
  /// Get all dockets
  Future<Either<Failure, List<DocketEntity>>> getDockets();
}
