import 'package:sqflite/sqflite.dart';
import '../../domain/entities/delivery_entities.dart';
import '../model/delivery_data_model.dart';
import 'delivery_data_source.dart';

/// Local delivery data source that loads from JSON files
class DeliveryLocalDataSourceImpl implements DeliveryDataSource {
  Database database;

  DeliveryLocalDataSourceImpl({required this.database});
  @override
  Future<DeliveryData> getDeliveryData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final data = await database.query('delivery_data');
      final deliveryDataModel = DeliveryDataModel.fromJson(data.first);
      return deliveryDataModel.toEntity();
    } catch (e) {
      throw Exception('Failed to load delivery data: $e');
    }
  }
}
