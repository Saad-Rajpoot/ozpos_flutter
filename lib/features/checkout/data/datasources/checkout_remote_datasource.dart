import 'package:dio/dio.dart';

import 'checkout_datasource.dart';
import '../../domain/entities/checkout_entity.dart';
import '../models/order_model.dart';
import '../models/checkout_data.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/exception_helper.dart';

class CheckoutRemoteDataSource implements CheckoutDataSource {
  final ApiClient _apiClient;
  CheckoutRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;
  @override
  Future<CheckoutEntity> saveOrder(OrderModel orderModel) async {
    // Save to remote data source
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final response = await _apiClient.post(AppConstants.createOrderEndpoint,
          data: orderModel.toJson());
      final payload = ExceptionHelper.validateResponseData(
        response.data,
        'saving order',
      );
      if (payload is! Map<String, dynamic>) {
        throw ServerException(
          message:
              'Invalid response format during saving order: expected Map, got ${payload.runtimeType}',
        );
      }
      final CheckoutEntity checkoutEntity =
          CheckoutData.fromJson(payload).toEntity();
      return checkoutEntity;
    } on DioException catch (e) {
      throw ExceptionHelper.handleDioException(e, 'saving order');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: 'Failed to save order: $e');
    }
  }
}
