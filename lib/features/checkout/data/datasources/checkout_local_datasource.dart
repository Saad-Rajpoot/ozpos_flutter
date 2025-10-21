import 'checkout_datasource.dart';
import '../../domain/entities/checkout_entity.dart';
import '../models/order_model.dart';
import '../models/checkout_data.dart';
import 'package:sqflite/sqflite.dart';

class CheckoutLocalDataSource implements CheckoutDataSource {
  final Database _database;

  CheckoutLocalDataSource({required Database database}) : _database = database;

  @override
  Future<CheckoutEntity> saveOrder(OrderModel orderModel) async {
    // Save to local database
    await _database.insert('orders', orderModel.toJson());
    return CheckoutData.fromJson(
      {
        'orders': (await _database
                .query('orders', where: 'id = ?', whereArgs: [orderModel.id]))
            .map((json) =>
                OrderModel.fromJson(json as Map<String, dynamic>).toEntity())
            .toList(),
        'metadata': CheckoutData.fromJson(
          (await _database.query('metadata'))[0],
        ).toEntity(),
      },
    ).toEntity();
  }
}
