import '../../domain/entities/order_entity.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/order_model.dart';
import 'orders_data_source.dart';
import '../../../../core/constants/app_constants.dart';

class OrdersRemoteDataSourceImpl implements OrdersDataSource {
  final ApiClient _apiClient;

  OrdersRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<OrderEntity>> getOrders() async {
    try {
      final response = await _apiClient.get(AppConstants.getOrdersEndpoint);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => OrderModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch orders');
    }
  }
}
