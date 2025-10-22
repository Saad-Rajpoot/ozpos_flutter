import '../models/menu_item_model.dart';
import '../models/menu_category_model.dart';

/// Menu data source interface - single abstraction for all menu data operations
abstract class MenuDataSource {
  /// Get all menu items
  Future<List<MenuItemModel>> getMenuItems();

  /// Get menu items by category
  Future<List<MenuItemModel>> getMenuItemsByCategory(String categoryId);

  /// Get menu item by ID
  Future<MenuItemModel> getMenuItemById(String id);

  /// Get all menu categories
  Future<List<MenuCategoryModel>> getMenuCategories();

  /// Get menu category by ID
  Future<MenuCategoryModel> getMenuCategoryById(String id);

  /// Search menu items
  Future<List<MenuItemModel>> searchMenuItems(String query);

  /// Get popular menu items
  Future<List<MenuItemModel>> getPopularMenuItems();
}
