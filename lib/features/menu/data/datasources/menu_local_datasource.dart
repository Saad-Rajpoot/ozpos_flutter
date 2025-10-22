import 'package:sqflite/sqflite.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/menu_item_model.dart';
import '../models/menu_category_model.dart';
import 'menu_data_source.dart';

/// Menu local data source implementation
class MenuLocalDataSourceImpl implements MenuDataSource {
  final Database database;

  MenuLocalDataSourceImpl({required this.database});

  @override
  Future<List<MenuItemModel>> getMenuItems() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'menu_items',
        orderBy: 'name ASC',
      );

      if (maps.isEmpty) {
        throw CacheException(message: 'No menu items found in local storage');
      }

      return maps.map((map) => MenuItemModel.fromJson(map)).toList();
    } catch (e) {
      throw CacheException(
          message:
              'Failed to fetch menu items from local storage: ${e.toString()}');
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
      throw CacheException(
          message:
              'Failed to fetch menu items by category from local storage: ${e.toString()}');
    }
  }

  @override
  Future<MenuItemModel> getMenuItemById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'menu_items',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) {
        throw CacheException(message: 'Menu item not found in local storage');
      }
      return MenuItemModel.fromJson(maps.first);
    } catch (e) {
      throw CacheException(
          message:
              'Failed to fetch menu item by ID from local storage: ${e.toString()}');
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

      if (maps.isEmpty) {
        throw CacheException(
            message: 'No menu categories found in local storage');
      }

      return maps.map((map) => MenuCategoryModel.fromJson(map)).toList();
    } catch (e) {
      throw CacheException(
          message:
              'Failed to fetch menu categories from local storage: ${e.toString()}');
    }
  }

  @override
  Future<MenuCategoryModel> getMenuCategoryById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'menu_categories',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) {
        throw CacheException(
            message: 'Menu category not found in local storage');
      }
      return MenuCategoryModel.fromJson(maps.first);
    } catch (e) {
      throw CacheException(
          message:
              'Failed to fetch menu category by ID from local storage: ${e.toString()}');
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
      throw CacheException(
          message:
              'Failed to search menu items in local storage: ${e.toString()}');
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
      throw CacheException(
          message:
              'Failed to fetch popular menu items from local storage: ${e.toString()}');
    }
  }
}
