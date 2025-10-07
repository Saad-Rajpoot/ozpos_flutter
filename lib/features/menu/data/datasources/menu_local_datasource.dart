import 'package:sqflite/sqflite.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/menu_item_model.dart';
import '../models/menu_category_model.dart';
import 'menu_mock_datasource.dart';

/// Menu local data source interface
abstract class MenuLocalDataSource {
  Future<List<MenuItemModel>> getMenuItems();
  Future<List<MenuItemModel>> getMenuItemsByCategory(String categoryId);
  Future<MenuItemModel?> getMenuItemById(String id);
  Future<List<MenuCategoryModel>> getMenuCategories();
  Future<MenuCategoryModel?> getMenuCategoryById(String id);
  Future<List<MenuItemModel>> searchMenuItems(String query);
  Future<List<MenuItemModel>> getPopularMenuItems();
  Future<void> cacheMenuItems(List<MenuItemModel> items);
  Future<void> cacheMenuCategories(List<MenuCategoryModel> categories);
  Future<void> clearCache();
}

/// Menu local data source implementation
class MenuLocalDataSourceImpl implements MenuLocalDataSource {
  final Database database;

  MenuLocalDataSourceImpl({required this.database});

  @override
  Future<List<MenuItemModel>> getMenuItems() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'menu_items',
        orderBy: 'name ASC',
      );
      // If database is empty, return mock data
      if (maps.isEmpty) {
        return MenuMockDataSource.getMockMenuItems();
      }
      return maps.map((map) => MenuItemModel.fromJson(map)).toList();
    } catch (e) {
      // For web or database errors, return mock data
      if (e.toString().contains('Database operations not supported on web') ||
          e.toString().contains('no such table')) {
        return MenuMockDataSource.getMockMenuItems();
      }
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<List<MenuItemModel>> getMenuItemsByCategory(String categoryId) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'menu_items',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'name ASC',
      );
      return maps.map((map) => MenuItemModel.fromJson(map)).toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<MenuItemModel?> getMenuItemById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'menu_items',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return MenuItemModel.fromJson(maps.first);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<List<MenuCategoryModel>> getMenuCategories() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'menu_categories',
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'sort_order ASC, name ASC',
      );
      // If database is empty, return mock data
      if (maps.isEmpty) {
        return MenuMockDataSource.getMockCategories();
      }
      return maps.map((map) => MenuCategoryModel.fromJson(map)).toList();
    } catch (e) {
      // For web or database errors, return mock data
      if (e.toString().contains('Database operations not supported on web') ||
          e.toString().contains('no such table')) {
        return MenuMockDataSource.getMockCategories();
      }
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<MenuCategoryModel?> getMenuCategoryById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'menu_categories',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return MenuCategoryModel.fromJson(maps.first);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<List<MenuItemModel>> searchMenuItems(String query) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'menu_items',
        where: 'name LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'name ASC',
      );
      return maps.map((map) => MenuItemModel.fromJson(map)).toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<List<MenuItemModel>> getPopularMenuItems() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'menu_items',
        where: 'tags LIKE ?',
        whereArgs: ['%Popular%'],
        orderBy: 'name ASC',
      );
      return maps.map((map) => MenuItemModel.fromJson(map)).toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheMenuItems(List<MenuItemModel> items) async {
    try {
      await database.transaction((txn) async {
        for (final item in items) {
          await txn.insert(
            'menu_items',
            item.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheMenuCategories(List<MenuCategoryModel> categories) async {
    try {
      await database.transaction((txn) async {
        for (final category in categories) {
          await txn.insert(
            'menu_categories',
            category.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await database.delete('menu_items');
      await database.delete('menu_categories');
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
