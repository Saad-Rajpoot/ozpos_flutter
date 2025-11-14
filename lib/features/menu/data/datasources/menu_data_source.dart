import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../models/menu_item_model.dart';
import '../models/menu_category_model.dart';

/// Menu data source interface - single abstraction for all menu data operations
abstract class MenuDataSource {
  /// Get all menu items
  Future<List<MenuItemModel>> getMenuItems();

  /// Get all menu items with pagination
  Future<PaginatedResponse<MenuItemModel>> getMenuItemsPaginated({
    PaginationParams? pagination,
  });

  /// Get menu items by category
  Future<List<MenuItemModel>> getMenuItemsByCategory(String categoryId);

  /// Get menu items by category with pagination
  Future<PaginatedResponse<MenuItemModel>> getMenuItemsByCategoryPaginated(
    String categoryId, {
    PaginationParams? pagination,
  });

  /// Get menu item by ID
  Future<MenuItemModel> getMenuItemById(String id);

  /// Get all menu categories
  Future<List<MenuCategoryModel>> getMenuCategories();

  /// Get all menu categories with pagination
  Future<PaginatedResponse<MenuCategoryModel>> getMenuCategoriesPaginated({
    PaginationParams? pagination,
  });

  /// Get menu category by ID
  Future<MenuCategoryModel> getMenuCategoryById(String id);

  /// Search menu items
  Future<List<MenuItemModel>> searchMenuItems(String query);

  /// Search menu items with pagination
  Future<PaginatedResponse<MenuItemModel>> searchMenuItemsPaginated(
    String query, {
    PaginationParams? pagination,
  });

  /// Get popular menu items
  Future<List<MenuItemModel>> getPopularMenuItems();

  /// Get popular menu items with pagination
  Future<PaginatedResponse<MenuItemModel>> getPopularMenuItemsPaginated({
    PaginationParams? pagination,
  });
}
