import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/table_entity.dart';

/// Table repository interface
abstract class TableRepository {
  /// Get all tables
  Future<Either<Failure, List<TableEntity>>> getTables();

  /// Get all available tables for move operations
  Future<Either<Failure, List<TableEntity>>> getMoveAvailableTables();
}
