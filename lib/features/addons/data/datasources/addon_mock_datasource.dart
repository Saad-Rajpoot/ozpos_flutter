import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/addon_management_entities.dart';
import '../model/addon_category_model.dart';
import 'addon_data_source.dart';

/// Mock add-on categories data source that loads from JSON files
class AddonMockDataSourceImpl implements AddonDataSource {
  /// Load addon categories from JSON file
  /// Simulates API behavior: tries to load success data, falls back to error data on failure
  @override
  Future<List<AddonCategory>> getAddonCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/addons_data/addon_categories.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((categoryData) {
        final categoryModel = AddonCategoryModel.fromJson(
          categoryData as Map<String, dynamic>,
        );
        return categoryModel.toEntity();
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/addons_data/addon_categories_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(
          errorData['message'] ?? 'Failed to load addon categories',
        );
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load addon categories: $e');
      }
    }
  }

  @override
  Future<PaginatedResponse<AddonCategory>> getAddonCategoriesPaginated({
    PaginationParams? pagination,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final params = pagination ?? const PaginationParams();
    final allCategories = await getAddonCategories();
    
    final totalItems = allCategories.length;
    final totalPages = (totalItems / params.limit).ceil();
    final startIndex = (params.page - 1) * params.limit;
    final endIndex = (startIndex + params.limit).clamp(0, totalItems);
    final paginatedCategories = allCategories.sublist(
      startIndex.clamp(0, totalItems),
      endIndex,
    );

    return PaginatedResponse<AddonCategory>(
      data: paginatedCategories,
      currentPage: params.page,
      totalPages: totalPages,
      totalItems: totalItems,
      perPage: params.limit,
    );
  }
}
