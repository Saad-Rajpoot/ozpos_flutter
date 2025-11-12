import 'checkout_datasource.dart';
import '../../domain/entities/checkout_entity.dart';
import '../../domain/entities/order_status.dart';
import '../models/checkout_data.dart';
import '../models/checkout_metadata.dart';
import '../models/order_model.dart';
import 'package:sqflite/sqflite.dart';

class CheckoutLocalDataSource implements CheckoutDataSource {
  final Database _database;

  CheckoutLocalDataSource({required Database database}) : _database = database;

  @override
  Future<CheckoutEntity> saveOrder(OrderModel orderModel) async {
    await _database.insert(
      'orders',
      _mapOrderToDatabase(orderModel),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final metadata = await _buildMetadata();

    return CheckoutData(
      orders: [orderModel],
      metadata: metadata,
    ).toEntity();
  }

  Map<String, dynamic> _mapOrderToDatabase(OrderModel orderModel) {
    final now = DateTime.now().toIso8601String();

    return {
      'id': orderModel.id,
      'order_number': orderModel.orderId,
      'order_type': orderModel.orderType.value,
      'status': orderModel.status.value,
      'table_number': orderModel.tableNumber,
      'customer_name': orderModel.customerName,
      'subtotal': orderModel.payment.subtotal,
      'tax_amount': orderModel.payment.tax,
      'tip_amount': orderModel.payment.tipAmount,
      'total_amount': orderModel.payment.grandTotal,
      'payment_method': orderModel.payment.method.value,
      'payment_status':
          orderModel.status == OrderStatus.completed ? 'paid' : 'unpaid',
      'created_at': orderModel.createdAt.toIso8601String(),
      'updated_at': orderModel.completedAt?.toIso8601String() ?? now,
    };
  }

  Future<CheckoutMetadata> _buildMetadata() async {
    final totalOrders = Sqflite.firstIntValue(
          await _database.rawQuery('SELECT COUNT(*) FROM orders'),
        ) ??
        0;

    final completedOrders = Sqflite.firstIntValue(
          await _database.rawQuery(
            'SELECT COUNT(*) FROM orders WHERE status = ?',
            ['completed'],
          ),
        ) ??
        0;

    final pendingOrders = Sqflite.firstIntValue(
          await _database.rawQuery(
            'SELECT COUNT(*) FROM orders WHERE status NOT IN (?, ?)',
            ['completed', 'cancelled'],
          ),
        ) ??
        0;

    final totals = await _database.rawQuery(
      '''
      SELECT
        COALESCE(SUM(total_amount), 0) AS total_revenue,
        COALESCE(AVG(total_amount), 0) AS average_order_value
      FROM orders
      ''',
    );

    final totalRevenue =
        (totals.first['total_revenue'] as num?)?.toDouble() ?? 0.0;
    final averageOrderValue =
        (totals.first['average_order_value'] as num?)?.toDouble() ?? 0.0;

    final lastUpdatedResult = await _database.rawQuery(
      'SELECT MAX(updated_at) AS last_updated FROM orders',
    );
    final lastUpdatedString =
        lastUpdatedResult.first['last_updated'] as String?;
    final lastUpdated = lastUpdatedString != null
        ? DateTime.tryParse(lastUpdatedString) ?? DateTime.now()
        : DateTime.now();

    return CheckoutMetadata(
      totalOrders: totalOrders,
      completedOrders: completedOrders,
      pendingOrders: pendingOrders,
      totalRevenue: totalRevenue,
      averageOrderValue: averageOrderValue,
      lastUpdated: lastUpdated,
    );
  }
}
