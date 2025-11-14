import '../../domain/entities/addon_management_entities.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../model/addon_category_model.dart';
import 'addon_data_source.dart';
import 'package:sqflite/sqflite.dart';

class AddonLocalDataSourceImpl implements AddonDataSource {
  final Database database;

  AddonLocalDataSourceImpl({required this.database});

  @override
  Future<List<AddonCategory>> getAddonCategories() async {
    try {
      // Assuming a local table named 'addon_categories'
      final List<Map<String, dynamic>> maps = await database.query(
        'addon_categories',
      );
      return maps
          .map((json) => AddonCategoryModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch addon categories from local database',
      );
    }
  }

  @override
  Future<PaginatedResponse<AddonCategory>> getAddonCategoriesPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final allMaps = await database.query('addon_categories');
      final allItems = allMaps
          .map((json) => AddonCategoryModel.fromJson(json).toEntity())
          .toList();
      
      final totalItems = allItems.length;
      final totalPages = (totalItems / params.limit).ceil();
      final startIndex = (params.page - 1) * params.limit;
      final endIndex = (startIndex + params.limit).clamp(0, totalItems);
      final paginatedItems = allItems.sublist(
        startIndex.clamp(0, totalItems),
        endIndex,
      );

      return PaginatedResponse<AddonCategory>(
        data: paginatedItems,
        currentPage: params.page,
        totalPages: totalPages,
        totalItems: totalItems,
        perPage: params.limit,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch addon categories from local database',
      );
    }
  }
}
