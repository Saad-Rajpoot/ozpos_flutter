import '../../domain/entities/table_entity.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/models/pagination_params.dart';
import '../../../../core/models/paginated_response.dart';
import '../models/table_model.dart';
import 'table_data_source.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/exception_helper.dart';

class TableRemoteDataSourceImpl implements TableDataSource {
  final ApiClient _apiClient;

  TableRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<TableEntity>> getTables() async {
    try {
      final response = await _apiClient.get(AppConstants.getTablesEndpoint);
      final List<dynamic> data = ExceptionHelper.validateListResponse(
        response.data,
        'fetching tables',
      );
      return data.map((json) => TableModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch tables');
    }
  }

  @override
  Future<PaginatedResponse<TableEntity>> getTablesPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final response = await _apiClient.get(
        AppConstants.getTablesEndpoint,
        queryParameters: params.toQueryParams(),
      );
      return ExceptionHelper.validatePaginatedResponse<TableEntity>(
        response.data,
        (json) => TableModel.fromJson(json).toEntity(),
        'fetching tables',
      );
    } catch (e) {
      throw ServerException(message: 'Failed to fetch tables');
    }
  }

  @override
  Future<List<TableEntity>> getMoveAvailableTables() async {
    try {
      final response = await _apiClient.get(AppConstants.getMoveTablesEndpoint);
      final List<dynamic> data = ExceptionHelper.validateListResponse(
        response.data,
        'fetching available tables',
      );
      return data.map((json) => TableModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch available tables');
    }
  }

  @override
  Future<PaginatedResponse<TableEntity>> getMoveAvailableTablesPaginated({
    PaginationParams? pagination,
  }) async {
    try {
      final params = pagination ?? const PaginationParams();
      final response = await _apiClient.get(
        AppConstants.getMoveTablesEndpoint,
        queryParameters: params.toQueryParams(),
      );
      return ExceptionHelper.validatePaginatedResponse<TableEntity>(
        response.data,
        (json) => TableModel.fromJson(json).toEntity(),
        'fetching available tables',
      );
    } catch (e) {
      throw ServerException(message: 'Failed to fetch available tables');
    }
  }
}
