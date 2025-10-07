import '../models/menu_item_model.dart';
import '../models/menu_category_model.dart';
import 'menu_local_datasource.dart';
import 'menu_mock_datasource.dart';

/// Mock menu local data source for web platform
class MockMenuLocalDataSource implements MenuLocalDataSource {
  @override
  Future<List<MenuItemModel>> getMenuItems() async {
    // Return mock data for web
    return MenuMockDataSourceImpl().getMenuItems();
  }

  @override
  Future<List<MenuItemModel>> getMenuItemsByCategory(String categoryId) async {
    final allItems = await MenuMockDataSourceImpl().getMenuItems();
    return allItems.where((item) => item.categoryId == categoryId).toList();
  }

  @override
  Future<MenuItemModel?> getMenuItemById(String id) async {
    final allItems = await MenuMockDataSourceImpl().getMenuItems();
    try {
      return allItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<MenuCategoryModel>> getMenuCategories() async {
    return MenuMockDataSourceImpl().getMenuCategories();
  }

  @override
  Future<MenuCategoryModel?> getMenuCategoryById(String id) async {
    final allCategories = await MenuMockDataSourceImpl().getMenuCategories();
    try {
      return allCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<MenuItemModel>> searchMenuItems(String query) async {
    final allItems = await MenuMockDataSourceImpl().getMenuItems();
    return allItems
        .where(
          (item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<List<MenuItemModel>> getPopularMenuItems() async {
    final allItems = await MenuMockDataSourceImpl().getMenuItems();
    return allItems.where((item) => item.tags.contains('Popular')).toList();
  }

  @override
  Future<void> cacheMenuItems(List<MenuItemModel> items) async {
    // No-op for web
  }

  @override
  Future<void> cacheMenuCategories(List<MenuCategoryModel> categories) async {
    // No-op for web
  }

  @override
  Future<void> clearCache() async {
    // No-op for web
  }
}
