import '../../../../core/errors/exceptions.dart';
import 'settings_data_source.dart';
import '../../domain/entities/settings_entities.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/settings_category_model.dart';

/// Remote settings data source (stub)
class SettingsRemoteDataSourceImpl implements SettingsDataSource {
  final ApiClient _apiClient;

  SettingsRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<SettingsCategoryEntity>> getCategories() async {
    try {
      final response = await _apiClient.get(AppConstants.getSettingsEndpoint);
      final List<dynamic> data = response.data['data'];
      return data
          .map((json) => SettingsCategoryModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch settings categories');
    }
  }
}
