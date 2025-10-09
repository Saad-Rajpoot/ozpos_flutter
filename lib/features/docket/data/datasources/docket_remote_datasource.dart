import '../../domain/entities/docket_management_entities.dart';
import 'docket_data_source.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/docket_model.dart';
import '../../../../core/constants/app_constants.dart';

/// Remote data source implementation for dockets
/// This would typically make HTTP requests to a REST API
class DocketRemoteDataSourceImpl implements DocketDataSource {
  final ApiClient _apiClient;

  DocketRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<DocketEntity>> getDockets() async {
    try {
      final response = await _apiClient.get(AppConstants.getDocketsEndpoint);
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List)
          .map((json) => DocketModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
