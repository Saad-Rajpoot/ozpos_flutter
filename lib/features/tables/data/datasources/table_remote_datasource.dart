import '../../domain/entities/table_entity.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
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
}
