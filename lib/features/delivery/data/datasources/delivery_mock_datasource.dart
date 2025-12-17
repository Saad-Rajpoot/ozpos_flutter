import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/entities/delivery_entities.dart';
import '../model/delivery_data_model.dart';
import 'delivery_data_source.dart';

/// Mock delivery data source that loads from JSON files
class DeliveryMockDataSourceImpl implements DeliveryDataSource {
  /// Load delivery data from JSON file
  /// Simulates API behavior: tries to load success data, falls back to error data on failure
  @override
  Future<DeliveryData> getDeliveryData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/delivery_data/delivery_data.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final deliveryDataModel = DeliveryDataModel.fromJson(jsonData);
      return deliveryDataModel.toEntity();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/delivery_data/delivery_data_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(errorData['message'] ?? 'Failed to load delivery data');
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load delivery data: $e');
      }
    }
  }
}
