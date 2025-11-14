import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/table_entity.dart';

/// Remote data source interface for tables
abstract class TableDataSource {
  /// Get all tables
  Future<List<TableEntity>> getTables();

  /// Get all tables with pagination
  Future<PaginatedResponse<TableEntity>> getTablesPaginated({
    PaginationParams? pagination,
  });

  /// Get all available tables for move operations
  Future<List<TableEntity>> getMoveAvailableTables();

  /// Get all available tables for move operations with pagination
  Future<PaginatedResponse<TableEntity>> getMoveAvailableTablesPaginated({
    PaginationParams? pagination,
  });
}
