import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/repository_error_handler.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_data_source.dart';

/// Menu repository implementation
class MenuRepositoryImpl implements MenuRepository {
  final MenuDataSource menuDataSource;
  final NetworkInfo networkInfo;

  MenuRepositoryImpl({
    required this.menuDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems() async {
    return RepositoryErrorHandler.handleOperation<List<MenuItemEntity>>(
      operation: () async {
        final items = await menuDataSource.getMenuItems();
        return items.map((model) => model.toEntity()).toList();
      },
      networkInfo: networkInfo,
      operationName: 'loading menu items',
    );
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItemsByCategory(
    String categoryId,
  ) async {
    return RepositoryErrorHandler.handleOperation<List<MenuItemEntity>>(
      operation: () async {
        final items = await menuDataSource.getMenuItemsByCategory(categoryId);
        return items.map((model) => model.toEntity()).toList();
      },
      networkInfo: networkInfo,
      operationName: 'loading menu items by category',
    );
  }

  @override
  Future<Either<Failure, MenuItemEntity>> getMenuItemById(String id) async {
    return RepositoryErrorHandler.handleOperation<MenuItemEntity>(
      operation: () async {
        final item = await menuDataSource.getMenuItemById(id);
        return item.toEntity();
      },
      networkInfo: networkInfo,
      operationName: 'loading menu item',
    );
  }

  @override
  Future<Either<Failure, List<MenuCategoryEntity>>> getMenuCategories() async {
    return RepositoryErrorHandler.handleOperation<List<MenuCategoryEntity>>(
      operation: () async {
        final categories = await menuDataSource.getMenuCategories();
        return categories.map((model) => model.toEntity()).toList();
      },
      networkInfo: networkInfo,
      operationName: 'loading menu categories',
    );
  }

  @override
  Future<Either<Failure, MenuCategoryEntity>> getMenuCategoryById(
      String id) async {
    return RepositoryErrorHandler.handleOperation<MenuCategoryEntity>(
      operation: () async {
        final category = await menuDataSource.getMenuCategoryById(id);
        return category.toEntity();
      },
      networkInfo: networkInfo,
      operationName: 'loading menu category',
    );
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> searchMenuItems(
      String query) async {
    return RepositoryErrorHandler.handleOperation<List<MenuItemEntity>>(
      operation: () async {
        final items = await menuDataSource.searchMenuItems(query);
        return items.map((model) => model.toEntity()).toList();
      },
      networkInfo: networkInfo,
      operationName: 'searching menu items',
    );
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getPopularMenuItems() async {
    return RepositoryErrorHandler.handleOperation<List<MenuItemEntity>>(
      operation: () async {
        final items = await menuDataSource.getPopularMenuItems();
        return items.map((model) => model.toEntity()).toList();
      },
      networkInfo: networkInfo,
      operationName: 'loading popular menu items',
    );
  }

  @override
  Future<Either<Failure, void>> refreshMenuData() async {
    return RepositoryErrorHandler.handleOperation<void>(
      operation: () async {
        await menuDataSource.getMenuItems();
        await menuDataSource.getMenuCategories();
      },
      networkInfo: networkInfo,
      operationName: 'refreshing menu data',
    );
  }
}
