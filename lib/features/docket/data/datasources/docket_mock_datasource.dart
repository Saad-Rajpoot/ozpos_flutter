import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/entities/docket_management_entities.dart';
import '../models/docket_model.dart';
import 'docket_data_source.dart';

/// Mock docket data source that loads from JSON files
class DocketMockDataSourceImpl implements DocketDataSource {
  /// Load dockets from JSON file
  /// Simulates API behavior: tries to load success data, falls back to error data on failure
  @override
  Future<List<DocketEntity>> getDockets() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/docket_data/docket_success.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((docketData) {
        final docketModel = DocketModel.fromJson(
          docketData as Map<String, dynamic>,
        );
        return docketModel.toEntity();
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/docket_data/docket_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(errorData['message'] ?? 'Failed to load dockets');
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load dockets: $e');
      }
    }
  }
}
