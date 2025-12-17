import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/entities/reports_entities.dart';
import '../models/reports_model.dart';
import 'reports_data_source.dart';

/// Mock reports data source that loads from JSON files
class ReportsMockDataSourceImpl implements ReportsDataSource {
  /// Load reports data from JSON file
  /// Simulates API behavior: tries to load success data, falls back to error data on failure
  @override
  Future<ReportsData> getReportsData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/reports_data/reports_success.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final reportsModel = ReportsModel.fromJson(jsonData);
      return reportsModel.toEntity();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/reports_data/reports_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(errorData['message'] ?? 'Failed to load reports data');
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load reports data: $e');
      }
    }
  }
}
