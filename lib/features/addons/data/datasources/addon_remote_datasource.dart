import '../../domain/entities/addon_management_entities.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../model/addon_category_model.dart';
import 'addon_data_source.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/exception_helper.dart';

class AddonRemoteDataSourceImpl implements AddonDataSource {
  final ApiClient _apiClient;

  AddonRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<AddonCategory>> getAddonCategories() async {
    try {
      final response = await _apiClient.get(
        AppConstants.getAddonCategoriesEndpoint,
      );
      final List<dynamic> data = ExceptionHelper.validateListResponse(
        response.data,
        'fetching addon categories',
      );
      return data
          .map((json) => AddonCategoryModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch addon categories');
    }
  }

  @override
  Future<PaginatedResponse<AddonCategory>> getAddonCategoriesPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final response = await _apiClient.get(
        AppConstants.getAddonCategoriesEndpoint,
        queryParameters: params.toQueryParams(),
      );
      return ExceptionHelper.validatePaginatedResponse<AddonCategory>(
        response.data,
        (json) => AddonCategoryModel.fromJson(json).toEntity(),
        'fetching addon categories',
      );
    } catch (e) {
      throw ServerException(message: 'Failed to fetch addon categories');
    }
  }
}
