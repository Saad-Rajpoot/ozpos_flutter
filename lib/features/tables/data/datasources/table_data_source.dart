import '../../domain/entities/table_entity.dart';

/// Remote data source interface for tables
abstract class TableDataSource {
  /// Get all tables
  Future<List<TableEntity>> getTables();

  /// Get all available tables for move operations
  Future<List<TableEntity>> getMoveAvailableTables();
}
