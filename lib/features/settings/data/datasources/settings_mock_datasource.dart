import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/settings_category_model.dart';
import 'settings_data_source.dart';
import '../../domain/entities/settings_entities.dart';

/// Mock settings data source. Loads either real or error mock from assets/settings_data.
class SettingsMockDataSourceImpl implements SettingsDataSource {
  static const _successFile = 'assets/settings_data/categories.json';
  static const _errorFile = 'assets/settings_data/categories_error.json';

  @override
  Future<List<SettingsCategoryEntity>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final jsonString = await rootBundle.loadString(_successFile);
      final List<dynamic> list = json.decode(jsonString);
      return list
          .map((e) => SettingsCategoryModel.fromJson(e as Map<String, dynamic>)
              .toEntity())
          .toList();
    } catch (e) {
      try {
        final errorJsonString = await rootBundle.loadString(_errorFile);
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(errorData['message'] ?? 'Failed to load settings');
      } catch (errorFile) {
        throw Exception('Failed to load settings: ${e.toString()}');
      }
    }
  }
}
