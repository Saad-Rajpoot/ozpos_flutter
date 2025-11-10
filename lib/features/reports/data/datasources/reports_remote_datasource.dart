import 'package:dio/dio.dart';

import '../../domain/entities/reports_entities.dart';
import '../models/reports_model.dart';
import 'reports_data_source.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/exception_helper.dart';

/// Remote reports data source that loads from API
class ReportsRemoteDataSourceImpl implements ReportsDataSource {
  final ApiClient apiClient;

  ReportsRemoteDataSourceImpl({required this.apiClient});

  /// Load reports data from remote API
  @override
  Future<ReportsData> getReportsData() async {
    final endpoint = AppConstants.getReportsEndpoint;
    try {
      final response = await apiClient.get(endpoint);

      if (response.statusCode == 200) {
        final payload = response.data;
        if (payload is! Map<String, dynamic>) {
          throw ServerException(
            message:
                'Invalid response format during fetching reports data: expected Map, got ${payload.runtimeType}',
          );
        }
        final reportsModel = ReportsModel.fromJson(payload);
        return reportsModel.toEntity();
      } else {
        throw ServerException(
          message: 'Failed to load reports data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'fetching reports data');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: 'Failed to load reports data: $e');
    }
  }
}
