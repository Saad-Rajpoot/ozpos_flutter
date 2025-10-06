import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/menu_item_entity.dart';
import '../entities/menu_category_entity.dart';

/// Menu repository interface
abstract class MenuRepository {
  /// Get all menu items
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems();

  /// Get menu items by category
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItemsByCategory(String categoryId);

  /// Get menu item by ID
  Future<Either<Failure, MenuItemEntity>> getMenuItemById(String id);

  /// Get all menu categories
  Future<Either<Failure, List<MenuCategoryEntity>>> getMenuCategories();

  /// Get menu category by ID
  Future<Either<Failure, MenuCategoryEntity>> getMenuCategoryById(String id);

  /// Search menu items
  Future<Either<Failure, List<MenuItemEntity>>> searchMenuItems(String query);

  /// Get popular menu items
  Future<Either<Failure, List<MenuItemEntity>>> getPopularMenuItems();

  /// Refresh menu data from server
  Future<Either<Failure, void>> refreshMenuData();
}
