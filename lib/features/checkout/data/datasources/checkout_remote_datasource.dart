import 'package:dio/dio.dart';

import 'checkout_datasource.dart';
import '../../domain/entities/checkout_entity.dart';
import '../models/order_model.dart';
import '../models/checkout_data.dart';
import '../models/book_order_request.dart';
import '../models/book_order_response.dart';
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

  @override
  Future<BookOrderSuccessResponse> bookOrder(BookOrderRequest request) async {
    try {
      final response = await _apiClient.post(
        AppConstants.bookOrderEndpoint,
        data: request.toJson(),
      );

      // Book-order API returns payload at top level, not under "data"
      final payload = response.data;
      if (payload == null || payload is! Map<String, dynamic>) {
        throw ServerException(
          message:
              'Invalid response format during booking order: expected Map, got ${payload?.runtimeType ?? 'null'}',
        );
      }

      final ok = payload['ok'] as bool? ?? false;
      final success = payload['success'] as bool? ?? false;
      if (!ok || !success) {
        final errorRes = BookOrderErrorResponse.fromJson(payload);
        throw ServerException(message: errorRes.error);
      }

      return BookOrderSuccessResponse.fromJson(payload);
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        final error = data['error'] as String? ?? data['message'] as String? ?? e.message ?? 'Unknown error';
        throw ServerException(message: error);
      }
      throw ExceptionHelper.handleDioException(e, 'booking order');
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(message: 'Failed to book order: $e');
    }
  }
}
