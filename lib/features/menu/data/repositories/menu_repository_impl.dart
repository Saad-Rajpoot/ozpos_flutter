import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_data_source.dart';

/// Menu repository implementation
class MenuRepositoryImpl implements MenuRepository {
  final MenuDataSource menuDataSource;

  MenuRepositoryImpl({
    required this.menuDataSource,
  });

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems() async {
    try {
      final items = await menuDataSource.getMenuItems();
      return Right(items.map((model) => model.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load menu items: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItemsByCategory(
    String categoryId,
  ) async {
    try {
      final items = await menuDataSource.getMenuItemsByCategory(categoryId);
      return Right(items.map((model) => model.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: 'Server error'));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to load menu items by category: $e'));
    }
  }

  @override
  Future<Either<Failure, MenuItemEntity>> getMenuItemById(String id) async {
    try {
      final item = await menuDataSource.getMenuItemById(id);
      return Right(item.toEntity());
    } on ServerException {
      return Left(ServerFailure(message: 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load menu item: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MenuCategoryEntity>>> getMenuCategories() async {
    try {
      final categories = await menuDataSource.getMenuCategories();
      return Right(categories.map((model) => model.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load menu categories: $e'));
    }
  }

  @override
  Future<Either<Failure, MenuCategoryEntity>> getMenuCategoryById(
      String id) async {
    try {
      final category = await menuDataSource.getMenuCategoryById(id);
      return Right(category.toEntity());
    } on ServerException {
      return Left(ServerFailure(message: 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load menu category: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> searchMenuItems(
      String query) async {
    try {
      final items = await menuDataSource.searchMenuItems(query);
      return Right(items.map((model) => model.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search menu items: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getPopularMenuItems() async {
    try {
      final items = await menuDataSource.getPopularMenuItems();
      return Right(items.map((model) => model.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure(message: 'Server error'));
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to load popular menu items: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> refreshMenuData() async {
    try {
      await menuDataSource.getMenuItems();
      await menuDataSource.getMenuCategories();
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure(message: 'Server error'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to refresh menu data: $e'));
    }
  }
}
