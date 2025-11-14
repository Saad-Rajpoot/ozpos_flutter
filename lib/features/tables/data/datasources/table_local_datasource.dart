import '../../domain/entities/table_entity.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../models/table_model.dart';
import 'table_data_source.dart';
import 'package:sqflite/sqflite.dart';

class TableLocalDataSourceImpl implements TableDataSource {
  final Database database;

  TableLocalDataSourceImpl({required this.database});

  @override
  Future<List<TableEntity>> getTables() async {
    try {
      // Assuming a local table named 'tables'
      final List<Map<String, dynamic>> maps = await database.query('tables');
      return maps.map((json) => TableModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch tables from local database',
      );
    }
  }

  @override
  Future<List<TableEntity>> getMoveAvailableTables() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'move_tables',
      );
      return maps.map((json) => TableModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch move available tables from local database',
      );
    }
  }

  @override
  Future<PaginatedResponse<TableEntity>> getTablesPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final allMaps = await database.query('tables');
      final allItems = allMaps
          .map((json) => TableModel.fromJson(json).toEntity())
          .toList();
      
      final totalItems = allItems.length;
      final totalPages = (totalItems / params.limit).ceil();
      final startIndex = (params.page - 1) * params.limit;
      final endIndex = (startIndex + params.limit).clamp(0, totalItems);
      final paginatedItems = allItems.sublist(
        startIndex.clamp(0, totalItems),
        endIndex,
      );

      return PaginatedResponse<TableEntity>(
        data: paginatedItems,
        currentPage: params.page,
        totalPages: totalPages,
        totalItems: totalItems,
        perPage: params.limit,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch tables from local database',
      );
    }
  }

  @override
  Future<PaginatedResponse<TableEntity>> getMoveAvailableTablesPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final allMaps = await database.query('move_tables');
      final allItems = allMaps
          .map((json) => TableModel.fromJson(json).toEntity())
          .toList();
      
      final totalItems = allItems.length;
      final totalPages = (totalItems / params.limit).ceil();
      final startIndex = (params.page - 1) * params.limit;
      final endIndex = (startIndex + params.limit).clamp(0, totalItems);
      final paginatedItems = allItems.sublist(
        startIndex.clamp(0, totalItems),
        endIndex,
      );

      return PaginatedResponse<TableEntity>(
        data: paginatedItems,
        currentPage: params.page,
        totalPages: totalPages,
        totalItems: totalItems,
        perPage: params.limit,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch move available tables from local database',
      );
    }
  }
}
