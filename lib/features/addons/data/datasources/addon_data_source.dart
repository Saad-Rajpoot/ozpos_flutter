import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/addon_management_entities.dart';

/// Remote data source interface for addons
abstract class AddonDataSource {
  /// Get all addon categories
  Future<List<AddonCategory>> getAddonCategories();

  /// Get all addon categories with pagination
  Future<PaginatedResponse<AddonCategory>> getAddonCategoriesPaginated({
    PaginationParams? pagination,
  });
}
