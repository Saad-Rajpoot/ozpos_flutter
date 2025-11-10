import 'package:dio/dio.dart';

import '../../domain/entities/delivery_entities.dart';
import '../model/delivery_data_model.dart';
import 'delivery_data_source.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/exception_helper.dart';

/// Remote delivery data source that loads from API
class DeliveryRemoteDataSourceImpl implements DeliveryDataSource {
  final ApiClient apiClient;

  DeliveryRemoteDataSourceImpl({required this.apiClient});

  /// Load delivery data from API
  @override
  Future<DeliveryData> getDeliveryData() async {
    try {
      final response =
          await apiClient.get(AppConstants.getDeliveryJobsEndpoint);

      if (response.statusCode == 200) {
        final payload = response.data;
        if (payload is! Map<String, dynamic>) {
          throw ServerException(
            message:
                'Invalid response format during fetching delivery data: expected Map, got ${payload.runtimeType}',
          );
        }
        final Map<String, dynamic> jsonData = payload;
        final deliveryDataModel = DeliveryDataModel.fromJson(jsonData);
        return deliveryDataModel.toEntity();
      } else {
        throw ServerException(
          message: 'Failed to load delivery data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'fetching delivery data');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: 'Failed to load delivery data: $e');
    }
  }
}
