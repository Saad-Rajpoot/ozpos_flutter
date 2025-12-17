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
    final result = await _database.rawQuery(
      '''
      SELECT
        COUNT(*) AS total_orders,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_orders,
        SUM(
          CASE
            WHEN status NOT IN ('completed', 'cancelled') THEN 1
            ELSE 0
          END
        ) AS pending_orders,
        COALESCE(SUM(total_amount), 0) AS total_revenue,
        COALESCE(AVG(total_amount), 0) AS average_order_value,
        MAX(updated_at) AS last_updated
      FROM orders
      ''',
    );

    final row = result.isNotEmpty ? result.first : <String, Object?>{};

    final totalOrders = (row['total_orders'] as num?)?.toInt() ?? 0;
    final completedOrders = (row['completed_orders'] as num?)?.toInt() ?? 0;
    final pendingOrders = (row['pending_orders'] as num?)?.toInt() ?? 0;
    final totalRevenue = (row['total_revenue'] as num?)?.toDouble() ?? 0.0;
    final averageOrderValue =
        (row['average_order_value'] as num?)?.toDouble() ?? 0.0;
    final lastUpdatedString = row['last_updated'] as String?;
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
