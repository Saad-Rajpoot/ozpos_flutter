import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/menu_item_model.dart';
import '../models/menu_category_model.dart';

/// Menu remote data source interface
abstract class MenuRemoteDataSource {
  Future<List<MenuItemModel>> getMenuItems();
  Future<List<MenuItemModel>> getMenuItemsByCategory(String categoryId);
  Future<MenuItemModel> getMenuItemById(String id);
  Future<List<MenuCategoryModel>> getMenuCategories();
  Future<MenuCategoryModel> getMenuCategoryById(String id);
  Future<List<MenuItemModel>> searchMenuItems(String query);
  Future<List<MenuItemModel>> getPopularMenuItems();
}

/// Menu remote data source implementation
class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
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
      throw ServerException(message: e.toString());
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
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MenuItemModel> getMenuItemById(String id) async {
    try {
      final response = await apiClient.get('${AppConstants.getMenuItemsEndpoint}/$id');
      final data = response.data as Map<String, dynamic>;
      return MenuItemModel.fromJson(data['data']);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<MenuCategoryModel>> getMenuCategories() async {
    try {
      final response = await apiClient.get(AppConstants.getMenuCategoriesEndpoint);
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List)
          .map((json) => MenuCategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MenuCategoryModel> getMenuCategoryById(String id) async {
    try {
      final response = await apiClient.get('${AppConstants.getMenuCategoriesEndpoint}/$id');
      final data = response.data as Map<String, dynamic>;
      return MenuCategoryModel.fromJson(data['data']);
    } catch (e) {
      throw ServerException(message: e.toString());
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
      throw ServerException(message: e.toString());
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
      throw ServerException(message: e.toString());
    }
  }
}
