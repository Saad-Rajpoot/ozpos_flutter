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

  @override
  Future<List<MenuItemModel>> getMenuItems() async {
    try {
      final response = await apiClient.get(AppConstants.getMenuItemsEndpoint);
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List)
          .map((json) => MenuItemModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch menu items from server');
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
    } catch (e) {
      throw ServerException(
          message: 'Failed to fetch menu items by category from server');
    }
  }

  @override
  Future<MenuItemModel> getMenuItemById(String id) async {
    try {
      final response =
          await apiClient.get('${AppConstants.getMenuItemsEndpoint}/$id');
      final data = response.data as Map<String, dynamic>;
      return MenuItemModel.fromJson(data['data']);
    } catch (e) {
      throw ServerException(
          message: 'Failed to fetch menu item by ID from server');
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
    } catch (e) {
      throw ServerException(
          message: 'Failed to fetch menu categories from server');
    }
  }

  @override
  Future<MenuCategoryModel> getMenuCategoryById(String id) async {
    try {
      final response =
          await apiClient.get('${AppConstants.getMenuCategoriesEndpoint}/$id');
      final data = response.data as Map<String, dynamic>;
      return MenuCategoryModel.fromJson(data['data']);
    } catch (e) {
      throw ServerException(
          message: 'Failed to fetch menu category by ID from server');
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
    } catch (e) {
      throw ServerException(message: 'Failed to search menu items on server');
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
    } catch (e) {
      throw ServerException(
          message: 'Failed to fetch popular menu items from server');
    }
  }
}
