import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/customer_display_model.dart';
import 'customer_display_data_source.dart';
import '../../domain/entities/customer_display_entity.dart';

class CustomerDisplayMockDataSourceImpl implements CustomerDisplayDataSource {
  @override
  Future<CustomerDisplayEntity> getContent() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/customer_display_data/customer_display_data.json',
      );
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final customerDisplayModel = CustomerDisplayModel.fromJson(data);
      return customerDisplayModel.toEntity();
    } catch (e) {
      final errorJsonString = await rootBundle.loadString(
        'assets/customer_display_data/customer_display_error.json',
      );
      final errorData = json.decode(errorJsonString) as Map<String, dynamic>;
      throw Exception(
        errorData['message'] ?? 'Failed to load customer display data: $e',
      );
    }
  }
}
