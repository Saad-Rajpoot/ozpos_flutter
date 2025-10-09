import '../../domain/entities/delivery_entities.dart';
import '../model/delivery_data_model.dart';
import 'delivery_data_source.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';

/// Remote delivery data source that loads from API
class DeliveryRemoteDataSourceImpl implements DeliveryDataSource {
  final ApiClient client;

  DeliveryRemoteDataSourceImpl({required this.client});

  /// Load delivery data from API
  @override
  Future<DeliveryData> getDeliveryData() async {
    try {
      final response = await client.get(AppConstants.getDeliveryJobsEndpoint);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;
        final deliveryDataModel = DeliveryDataModel.fromJson(jsonData);
        return deliveryDataModel.toEntity();
      } else {
        throw Exception('Failed to load delivery data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load delivery data: $e');
    }
  }
}
