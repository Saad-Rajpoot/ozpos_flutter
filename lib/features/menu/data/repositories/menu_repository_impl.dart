import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_datasource.dart';
import '../datasources/menu_local_datasource.dart';
import '../datasources/menu_mock_datasource.dart';

/// Menu repository implementation
class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remoteDataSource;
  final MenuLocalDataSource? localDataSource;
  final NetworkInfo networkInfo;

  MenuRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems() async {
    // Try to get data from local/cache first (for better UX)
    final localResult = await _tryGetLocalMenuItems();
    if (localResult != null) {
      return localResult;
    }

    // Try remote if connected
    if (await networkInfo.isConnected) {
      try {
        final items = await remoteDataSource.getMenuItems();
        // Cache the remote data if local storage is available
        if (localDataSource != null) {
          await localDataSource!.cacheMenuItems(items);
        }
        return Right(items.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        // If remote fails, return the local result we got earlier (or mock as fallback)
        return localResult ?? Left(ServerFailure(message: e.message));
      }
    } else {
      // No network, return local result or mock as final fallback
      return localResult ?? const Right([]);
    }
  }

  Future<Either<Failure, List<MenuItemEntity>>?> _tryGetLocalMenuItems() async {
    try {
      if (localDataSource != null) {
        final items = await localDataSource!.getMenuItems();
        if (items.isNotEmpty) {
          return Right(items.map((model) => model.toEntity()).toList());
        }
      } else {
        // No local data source, use mock data as fallback
        final items = MenuMockDataSource.getMockMenuItems();
        if (items.isNotEmpty) {
          return Right(items.map((model) => model.toEntity()).toList());
        }
      }
    } catch (e) {
      // Local failed, will try remote next
    }
    return null;
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItemsByCategory(
    String categoryId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final items = await remoteDataSource.getMenuItemsByCategory(categoryId);
        return Right(items.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      if (localDataSource != null) {
        try {
          final items = await localDataSource!.getMenuItemsByCategory(
            categoryId,
          );
          return Right(items.map((model) => model.toEntity()).toList());
        } on CacheException catch (e) {
          return Left(CacheFailure(message: e.message));
        }
      } else {
        return Left(CacheFailure(message: 'No local data source available'));
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
      if (localDataSource != null) {
        try {
          final item = await localDataSource!.getMenuItemById(id);
          if (item == null) {
            return Left(CacheFailure(message: 'Menu item not found'));
          }
          return Right(item.toEntity());
        } on CacheException catch (e) {
          return Left(CacheFailure(message: e.message));
        }
      } else {
        return Left(CacheFailure(message: 'No local data source available'));
      }
    }
  }

  @override
  Future<Either<Failure, List<MenuCategoryEntity>>> getMenuCategories() async {
    // Try to get data from local/cache first (for better UX)
    final localResult = await _tryGetLocalMenuCategories();
    if (localResult != null) {
      return localResult;
    }

    // Try remote if connected
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getMenuCategories();
        // Cache the remote data if local storage is available
        if (localDataSource != null) {
          await localDataSource!.cacheMenuCategories(categories);
        }
        return Right(categories.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        // If remote fails, return the local result we got earlier (or mock as fallback)
        return localResult ?? Left(ServerFailure(message: e.message));
      }
    } else {
      // No network, return local result or mock as final fallback
      return localResult ?? const Right([]);
    }
  }

  Future<Either<Failure, List<MenuCategoryEntity>>?>
  _tryGetLocalMenuCategories() async {
    try {
      if (localDataSource != null) {
        final categories = await localDataSource!.getMenuCategories();
        if (categories.isNotEmpty) {
          return Right(categories.map((model) => model.toEntity()).toList());
        }
      } else {
        // No local data source, use mock data as fallback
        final categories = MenuMockDataSource.getMockCategories();
        if (categories.isNotEmpty) {
          return Right(categories.map((model) => model.toEntity()).toList());
        }
      }
    } catch (e) {
      // Local failed, will try remote next
    }
    return null;
  }

  @override
  Future<Either<Failure, MenuCategoryEntity>> getMenuCategoryById(
    String id,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final category = await remoteDataSource.getMenuCategoryById(id);
        return Right(category.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      if (localDataSource != null) {
        try {
          final category = await localDataSource!.getMenuCategoryById(id);
          if (category == null) {
            return Left(CacheFailure(message: 'Menu category not found'));
          }
          return Right(category.toEntity());
        } on CacheException catch (e) {
          return Left(CacheFailure(message: e.message));
        }
      } else {
        return Left(CacheFailure(message: 'No local data source available'));
      }
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> searchMenuItems(
    String query,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final items = await remoteDataSource.searchMenuItems(query);
        return Right(items.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      if (localDataSource != null) {
        try {
          final items = await localDataSource!.searchMenuItems(query);
          return Right(items.map((model) => model.toEntity()).toList());
        } on CacheException catch (e) {
          return Left(CacheFailure(message: e.message));
        }
      } else {
        return Left(CacheFailure(message: 'No local data source available'));
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
      if (localDataSource != null) {
        try {
          final items = await localDataSource!.getPopularMenuItems();
          return Right(items.map((model) => model.toEntity()).toList());
        } on CacheException catch (e) {
          return Left(CacheFailure(message: e.message));
        }
      } else {
        return Left(CacheFailure(message: 'No local data source available'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> refreshMenuData() async {
    if (await networkInfo.isConnected) {
      try {
        final items = await remoteDataSource.getMenuItems();
        final categories = await remoteDataSource.getMenuCategories();
        if (localDataSource != null) {
          await localDataSource!.cacheMenuItems(items);
          await localDataSource!.cacheMenuCategories(categories);
        }
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
