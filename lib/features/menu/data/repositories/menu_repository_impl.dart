import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
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
    if (await networkInfo.isConnected) {
      try {
        final items = await menuDataSource.getMenuItems();
        return Right(items.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(
            ServerFailure(message: 'Unexpected error loading menu items: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No network connection'));
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItemsByCategory(
    String categoryId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final items = await menuDataSource.getMenuItemsByCategory(categoryId);
        return Right(items.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(
            message: 'Unexpected error loading menu items by category: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No network connection'));
    }
  }

  @override
  Future<Either<Failure, MenuItemEntity>> getMenuItemById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final item = await menuDataSource.getMenuItemById(id);
        return Right(item.toEntity());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(
            ServerFailure(message: 'Unexpected error loading menu item: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No network connection'));
    }
  }

  @override
  Future<Either<Failure, List<MenuCategoryEntity>>> getMenuCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await menuDataSource.getMenuCategories();
        return Right(categories.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(
            message: 'Unexpected error loading menu categories: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No network connection'));
    }
  }

  @override
  Future<Either<Failure, MenuCategoryEntity>> getMenuCategoryById(
      String id) async {
    if (await networkInfo.isConnected) {
      try {
        final category = await menuDataSource.getMenuCategoryById(id);
        return Right(category.toEntity());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(
            message: 'Unexpected error loading menu category: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No network connection'));
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> searchMenuItems(
      String query) async {
    if (await networkInfo.isConnected) {
      try {
        final items = await menuDataSource.searchMenuItems(query);
        return Right(items.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(
            message: 'Unexpected error searching menu items: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No network connection'));
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getPopularMenuItems() async {
    if (await networkInfo.isConnected) {
      try {
        final items = await menuDataSource.getPopularMenuItems();
        return Right(items.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(
            message: 'Unexpected error loading popular menu items: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No network connection'));
    }
  }

  @override
  Future<Either<Failure, void>> refreshMenuData() async {
    if (await networkInfo.isConnected) {
      try {
        await menuDataSource.getMenuItems();
        await menuDataSource.getMenuCategories();
        return const Right(null);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(
            message: 'Unexpected error refreshing menu data: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No network connection'));
    }
  }
}
