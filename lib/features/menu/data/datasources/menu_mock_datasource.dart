import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/menu_item_model.dart';
import '../models/menu_category_model.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/modifier_group_entity.dart';
import '../../domain/entities/modifier_option_entity.dart';
import '../../../combos/domain/entities/combo_option_entity.dart';
import '../../../tables/domain/entities/table_entity.dart';
import 'menu_data_source.dart';

/// Mock menu data source implementation for testing without backend
class MenuMockDataSourceImpl implements MenuDataSource {
  /// Load categories from menu items seed data
  static Future<List<MenuCategoryModel>> _getMockCategories() async {
    try {
      // Load menu items and extract categories from them
      final jsonString = await rootBundle.loadString(
        'assets/menu_data/menu_items_seed.json',
      );
      final List<dynamic> menuItemsData = json.decode(jsonString);

      // Extract unique categories from menu items
      final Map<String, dynamic> categoriesMap = {};

      for (final item in menuItemsData) {
        final category = item['category'];
        if (category != null && category['id'] != null) {
          categoriesMap[category['id']] = category;
        }
      }

      // Convert to sorted list
      final categories = categoriesMap.values.toList();
      categories
          .sort((a, b) => (a['sortOrder'] ?? 0).compareTo(b['sortOrder'] ?? 0));

      return categories.map((category) {
        return MenuCategoryModel(
          id: category['id'],
          name: category['name'],
          description: category['description'],
          image: category['image'],
          isActive: category['isActive'] ?? true,
          sortOrder: category['sortOrder'] ?? 0,
          createdAt: DateTime.parse(
              category['createdAt'] ?? '2025-01-08T10:00:00.000Z'),
          updatedAt: DateTime.parse(
              category['updatedAt'] ?? '2025-01-08T10:00:00.000Z'),
        );
      }).toList();
    } catch (e) {
      // If loading fails, try loading error data as fallback
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
        'assets/menu_data/menu_items_seed.json',
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

  /// Load menu items from JSON file
  static Future<List<MenuItemEntity>> get menuItems async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/menu_data/menu_items_seed.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((item) {
        return MenuItemEntity(
          id: item['id'],
          categoryId: item['categoryId'],
          name: item['name'],
          description: item['description'],
          image: item['image'],
          basePrice: item['basePrice'].toDouble(),
          tags: item['tags'] != null ? List<String>.from(item['tags']) : [],
          modifierGroups: item['modifierGroups'] != null
              ? (item['modifierGroups'] as List<dynamic>).map((group) {
                  return ModifierGroupEntity(
                    id: group['id'],
                    name: group['name'],
                    isRequired: group['isRequired'] ?? false,
                    minSelection: group['minSelection'] ?? 0,
                    maxSelection: group['maxSelection'] ?? 1,
                    options: (group['options'] as List<dynamic>).map((option) {
                      return ModifierOptionEntity(
                        id: option['id'],
                        name: option['name'],
                        priceDelta: option['priceDelta'].toDouble(),
                        isDefault: option['isDefault'] ?? false,
                      );
                    }).toList(),
                  );
                }).toList()
              : [],
          comboOptions: item['comboOptions'] != null
              ? (item['comboOptions'] as List<dynamic>).map((combo) {
                  return ComboOptionEntity(
                    id: combo['id'],
                    name: combo['name'],
                    description: combo['description'],
                    priceDelta: combo['priceDelta'].toDouble(),
                  );
                }).toList()
              : [],
          recommendedAddOnIds: item['recommendedAddOnIds'] != null
              ? List<String>.from(item['recommendedAddOnIds'])
              : [],
        );
      }).toList();
    } catch (e) {
      // Fallback to empty list if JSON loading fails
      return [];
    }
  }

  /// Load tables from JSON file
  static Future<List<TableEntity>> get tables async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/seed_data/tables_seed.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((table) {
        return TableEntity(
          id: table['id'],
          number: table['number'],
          seats: table['seats'],
          status: _parseTableStatus(table['status']),
          serverName: table['serverName'],
          floorX: table['floorX'],
          floorY: table['floorY'],
        );
      }).toList();
    } catch (e) {
      // Fallback to empty list if JSON loading fails
      return [];
    }
  }

  /// Helper method to parse table status from string
  static TableStatus _parseTableStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return TableStatus.available;
      case 'occupied':
        return TableStatus.occupied;
      case 'reserved':
        return TableStatus.reserved;
      case 'cleaning':
        return TableStatus.cleaning;
      default:
        return TableStatus.available;
    }
  }
}

// Extension to add firstOrNull method if not available
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
