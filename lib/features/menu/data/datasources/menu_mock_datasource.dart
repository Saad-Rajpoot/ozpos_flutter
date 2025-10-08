import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/menu_item_model.dart';
import '../models/menu_category_model.dart';
import 'menu_remote_datasource.dart';

/// Mock menu data source implementation for testing without backend
/// Implements the same interface as MenuRemoteDataSource for proper interchangeability
class MenuMockDataSourceImpl implements MenuRemoteDataSource {
  /// Load categories from JSON file
  static Future<List<MenuCategoryModel>> _getMockCategories() async {
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/menu_data/categories.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((category) {
        return MenuCategoryModel(
          id: category['id'],
          name: category['name'],
          description: category['description'],
          image: category['image'],
          isActive: category['isActive'],
          sortOrder: category['sortOrder'],
          createdAt: DateTime.parse(category['createdAt']),
          updatedAt: DateTime.parse(category['updatedAt']),
        );
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/menu_data/categories_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(
          errorData['message'] ?? 'Failed to load menu categories',
        );
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load menu categories: $e');
      }
    }
  }

  /// Load menu items from JSON file
  static Future<List<MenuItemModel>> _getMockMenuItems() async {
    try {
      // Try to load success data first
      final jsonString = await rootBundle.loadString(
        'assets/menu_data/menu_items.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((item) {
        return MenuItemModel(
          id: item['id'],
          name: item['name'],
          description: item['description'],
          categoryId: item['categoryId'],
          basePrice: item['basePrice'].toDouble(),
          image: item['image'],
          tags: List<String>.from(item['tags'] ?? []),
        );
      }).toList();
    } catch (e) {
      // If success data fails to load, try loading error data
      try {
        final errorJsonString = await rootBundle.loadString(
          'assets/menu_data/menu_items_error.json',
        );
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw Exception(errorData['message'] ?? 'Failed to load menu items');
      } catch (errorLoadingError) {
        // If even error data fails, throw the original error
        throw Exception('Failed to load menu items: $e');
      }
    }
  }

  @override
  Future<List<MenuItemModel>> getMenuItems() async {
    // Simulate network delay for realistic testing
    await Future.delayed(const Duration(milliseconds: 500));

    return await _getMockMenuItems();
  }

  @override
  Future<List<MenuItemModel>> getMenuItemsByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final items = await _getMockMenuItems();
    return items.where((item) => item.categoryId == categoryId).toList();
  }

  @override
  Future<MenuItemModel> getMenuItemById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final items = await _getMockMenuItems();
    final item = items.where((item) => item.id == id).firstOrNull;
    if (item == null) {
      throw Exception('Menu item not found');
    }
    return item;
  }

  @override
  Future<List<MenuCategoryModel>> getMenuCategories() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return await _getMockCategories();
  }

  @override
  Future<MenuCategoryModel> getMenuCategoryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final categories = await _getMockCategories();
    final category = categories.where((cat) => cat.id == id).firstOrNull;
    if (category == null) {
      throw Exception('Menu category not found');
    }
    return category;
  }

  @override
  Future<List<MenuItemModel>> searchMenuItems(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final items = await _getMockMenuItems();
    final lowercaseQuery = query.toLowerCase();
    return items
        .where(
          (item) =>
              item.name.toLowerCase().contains(lowercaseQuery) ||
              item.description.toLowerCase().contains(lowercaseQuery) ||
              item.tags.any(
                (tag) => tag.toLowerCase().contains(lowercaseQuery),
              ),
        )
        .toList();
  }

  @override
  Future<List<MenuItemModel>> getPopularMenuItems() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final items = await _getMockMenuItems();
    return items
        .where(
          (item) =>
              item.tags.contains('Popular') ||
              item.tags.contains('Best Seller'),
        )
        .toList();
  }
}

// Extension to add firstOrNull method if not available
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
