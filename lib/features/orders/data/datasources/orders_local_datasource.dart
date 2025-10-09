import '../../domain/entities/order_entity.dart';
import '../../../../core/errors/exceptions.dart';
import 'orders_data_source.dart';
import 'package:sqflite/sqflite.dart';
import '../models/order_model.dart';

class OrdersLocalDataSourceImpl implements OrdersDataSource {
  final Database database;

  OrdersLocalDataSourceImpl({required this.database});

  @override
  Future<List<OrderEntity>> getOrders() async {
    try {
      // Assuming a local table named 'orders'
      final List<Map<String, dynamic>> maps = await database.query('orders');
      return maps.map((json) => OrderModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch orders from local database',
      );
    }
  }
}
