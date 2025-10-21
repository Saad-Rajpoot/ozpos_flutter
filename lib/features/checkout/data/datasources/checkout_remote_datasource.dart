import 'checkout_datasource.dart';
import '../../domain/entities/checkout_entity.dart';
import '../models/order_model.dart';
import '../models/checkout_data.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';

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
      final CheckoutEntity checkoutEntity =
          CheckoutData.fromJson(response.data).toEntity();
      return checkoutEntity;
    } catch (e) {
      throw ServerException(message: 'Failed to save order: $e');
    }
  }
}
