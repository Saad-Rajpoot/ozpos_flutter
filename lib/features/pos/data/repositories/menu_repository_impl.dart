import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_datasource.dart';
import '../datasources/menu_local_datasource.dart';

/// Menu repository implementation
class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remoteDataSource;
  final MenuLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MenuRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems() async {
    try {
      // Always try local/mock data first for development
      final items = await localDataSource.getMenuItems();
      if (items.isNotEmpty) {
        return Right(items.map((model) => model.toEntity()).toList());
      }
    } catch (e) {
      // Continue to remote if local fails
    }
    
    // Try remote if local is empty or fails
    if (await networkInfo.isConnected) {
      try {
        final items = await remoteDataSource.getMenuItems();
        await localDataSource.cacheMenuItems(items);
        return Right(items.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        // If remote fails, try local again as fallback
        try {
          final items = await localDataSource.getMenuItems();
          return Right(items.map((model) => model.toEntity()).toList());
        } catch (_) {
          return Left(ServerFailure(message: e.message));
        }
      }
    } else {
      try {
        final items = await localDataSource.getMenuItems();
        return Right(items.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItemsByCategory(String categoryId) async {
    if (await networkInfo.isConnected) {
      try {
        final items = await remoteDataSource.getMenuItemsByCategory(categoryId);
        return Right(items.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final items = await localDataSource.getMenuItemsByCategory(categoryId);
        return Right(items.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, MenuItemEntity>> getMenuItemById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final item = await remoteDataSource.getMenuItemById(id);
        return Right(item.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final item = await localDataSource.getMenuItemById(id);
        if (item == null) {
          return Left(CacheFailure(message: 'Menu item not found'));
        }
        return Right(item.toEntity());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<MenuCategoryEntity>>> getMenuCategories() async {
    try {
      // Always try local/mock data first for development
      final categories = await localDataSource.getMenuCategories();
      if (categories.isNotEmpty) {
        return Right(categories.map((model) => model.toEntity()).toList());
      }
    } catch (e) {
      // Continue to remote if local fails
    }
    
    // Try remote if local is empty or fails
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getMenuCategories();
        await localDataSource.cacheMenuCategories(categories);
        return Right(categories.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        // If remote fails, try local again as fallback
        try {
          final categories = await localDataSource.getMenuCategories();
          return Right(categories.map((model) => model.toEntity()).toList());
        } catch (_) {
          return Left(ServerFailure(message: e.message));
        }
      }
    } else {
      try {
        final categories = await localDataSource.getMenuCategories();
        return Right(categories.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, MenuCategoryEntity>> getMenuCategoryById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final category = await remoteDataSource.getMenuCategoryById(id);
        return Right(category.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final category = await localDataSource.getMenuCategoryById(id);
        if (category == null) {
          return Left(CacheFailure(message: 'Menu category not found'));
        }
        return Right(category.toEntity());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> searchMenuItems(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final items = await remoteDataSource.searchMenuItems(query);
        return Right(items.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final items = await localDataSource.searchMenuItems(query);
        return Right(items.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getPopularMenuItems() async {
    if (await networkInfo.isConnected) {
      try {
        final items = await remoteDataSource.getPopularMenuItems();
        return Right(items.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final items = await localDataSource.getPopularMenuItems();
        return Right(items.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, void>> refreshMenuData() async {
    if (await networkInfo.isConnected) {
      try {
        final items = await remoteDataSource.getMenuItems();
        final categories = await remoteDataSource.getMenuCategories();
        await localDataSource.cacheMenuItems(items);
        await localDataSource.cacheMenuCategories(categories);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
