import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reports_entities.dart';

/// Reports repository interface
abstract class ReportsRepository {
  /// Get all reports data
  Future<Either<Failure, ReportsData>> getReportsData();
}
