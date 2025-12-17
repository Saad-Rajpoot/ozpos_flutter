import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/customer_display_model.dart';
import 'customer_display_data_source.dart';
import '../../domain/entities/customer_display_entity.dart';

class CustomerDisplayRemoteDataSourceImpl implements CustomerDisplayDataSource {
  final ApiClient apiClient;

  CustomerDisplayRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CustomerDisplayEntity> getContent() async {
    try {
      final response =
          await apiClient.get(AppConstants.customerDisplayEndpoint);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          final customerDisplayModel = CustomerDisplayModel.fromJson(payload);
          return customerDisplayModel.toEntity();
        }
        final customerDisplayModel = CustomerDisplayModel.fromJson(data);
        return customerDisplayModel.toEntity();
      }
      throw ServerException(
        message: 'Invalid response format for customer display content',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
          message: 'Network error loading customer display: ${e.message}',
        );
      }
      throw ServerException(
        message: 'Server error loading customer display: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error loading customer display: $e',
      );
    }
  }
}
