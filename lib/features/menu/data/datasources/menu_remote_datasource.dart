import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/menu_item_model.dart';
import '../models/menu_category_model.dart';
import 'menu_data_source.dart';

/// Menu remote data source implementation
class MenuRemoteDataSourceImpl implements MenuDataSource {
  final ApiClient apiClient;

  MenuRemoteDataSourceImpl({required this.apiClient});

  /// Helper method to handle DioException and convert to appropriate exceptions
  Exception _handleDioException(DioException e, String operation) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkException(
          message: 'Network error during $operation: ${e.message}');
    } else {
      return ServerException(
          message: 'Server error during $operation: ${e.message}');
    }
  }

  @override
  Future<List<MenuItemModel>> getMenuItems() async {
    try {
      final response = await apiClient.get(AppConstants.getMenuItemsEndpoint);
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List)
          .map((json) => MenuItemModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e, 'fetching menu items');
    } catch (e) {
      throw ServerException(
          message: 'Unexpected error fetching menu items: $e');
    }
  }

  @override
  Future<List<MenuItemModel>> getMenuItemsByCategory(String categoryId) async {
    try {
      final response = await apiClient.get(
        '${AppConstants.getMenuItemsEndpoint}?category_id=$categoryId',
      );
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List)
          .map((json) => MenuItemModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e, 'fetching menu items by category');
    } catch (e) {
      throw ServerException(
          message: 'Unexpected error fetching menu items by category: $e');
    }
  }

  @override
  Future<MenuItemModel> getMenuItemById(String id) async {
    try {
      final response =
          await apiClient.get('${AppConstants.getMenuItemsEndpoint}/$id');
      final data = response.data as Map<String, dynamic>;
      return MenuItemModel.fromJson(data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e, 'fetching menu item by ID');
    } catch (e) {
      throw ServerException(
          message: 'Unexpected error fetching menu item by ID: $e');
    }
  }

  @override
  Future<List<MenuCategoryModel>> getMenuCategories() async {
    try {
      final response =
          await apiClient.get(AppConstants.getMenuCategoriesEndpoint);
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List)
          .map((json) => MenuCategoryModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e, 'fetching menu categories');
    } catch (e) {
      throw ServerException(
          message: 'Unexpected error fetching menu categories: $e');
    }
  }

  @override
  Future<MenuCategoryModel> getMenuCategoryById(String id) async {
    try {
      final response =
          await apiClient.get('${AppConstants.getMenuCategoriesEndpoint}/$id');
      final data = response.data as Map<String, dynamic>;
      return MenuCategoryModel.fromJson(data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e, 'fetching menu category by ID');
    } catch (e) {
      throw ServerException(
          message: 'Unexpected error fetching menu category by ID: $e');
    }
  }

  @override
  Future<List<MenuItemModel>> searchMenuItems(String query) async {
    try {
      final response = await apiClient.get(
        '${AppConstants.getMenuItemsEndpoint}?search=$query',
      );
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List)
          .map((json) => MenuItemModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e, 'searching menu items');
    } catch (e) {
      throw ServerException(
          message: 'Unexpected error searching menu items: $e');
    }
  }

  @override
  Future<List<MenuItemModel>> getPopularMenuItems() async {
    try {
      final response = await apiClient.get(
        '${AppConstants.getMenuItemsEndpoint}?popular=true',
      );
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List)
          .map((json) => MenuItemModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e, 'fetching popular menu items');
    } catch (e) {
      throw ServerException(
          message: 'Unexpected error fetching popular menu items: $e');
    }
  }
}
