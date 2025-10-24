import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/table_entity.dart';
import '../models/table_model.dart';
import 'table_data_source.dart';

/// Mock tables data source that loads from JSON files
class TableMockDataSourceImpl implements TableDataSource {
  /// Load tables from JSON file
  /// Simulates API behavior: tries to load success data, falls back to error data on failure
  @override
  Future<List<TableEntity>> getTables() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/tables_data/tables_data.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((tableData) {
        final tableModel = TableModel.fromJson(
          tableData as Map<String, dynamic>,
        );
        return tableModel.toEntity();
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/tables_data/tables_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw CacheException(
            message: errorData['message'] ?? 'Failed to load tables');
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw CacheException(message: 'Failed to load tables: $e');
      }
    }
  }

  /// Load available tables from JSON file for move operations
  /// Simulates API behavior: tries to load success data, falls back to error data on failure
  @override
  Future<List<TableEntity>> getMoveAvailableTables() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/tables_data/move_tables.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((tableData) {
        final tableModel = TableModel.fromJson(
          tableData as Map<String, dynamic>,
        );
        return tableModel.toEntity();
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/tables_data/move_tables_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw CacheException(
          message: errorData['message'] ?? 'Failed to load available tables',
        );
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw CacheException(message: 'Failed to load available tables: $e');
      }
    }
  }
}
