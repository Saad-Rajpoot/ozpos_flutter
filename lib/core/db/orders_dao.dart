import 'dart:convert';

import 'package:drift/drift.dart';

import '../../features/orders/domain/entities/order_entity.dart';
import '../../features/orders/domain/entities/order_item_entity.dart';
import 'pos_database.dart';

/// DAO for persisting and reading orders for offline-first order management.
class OrdersDao {
  OrdersDao(this._db);

  final PosDatabase _db;

  /// Replace all stored orders with the given history snapshot.
  ///
  /// This is used when loading order history from the remote API; it
  /// keeps Drift as the local source of truth for read paths.
  Future<void> replaceAllForHistory(List<OrderEntity> orders) async {
    await _db.transaction(() async {
      await _db.delete(_db.dbOrderItems).go();
      await _db.delete(_db.dbOrders).go();

      for (final order in orders) {
        await _db.into(_db.dbOrders).insert(
              DbOrdersCompanion(
                id: Value(order.id),
                queueNumber: Value(order.queueNumber),
                channel: Value(order.channel.name),
                orderType: Value(order.orderType.name),
                paymentStatus: Value(order.paymentStatus.name),
                status: Value(order.status.name),
                customerName: Value(order.customerName),
                customerPhone: Value(order.customerPhone),
                subtotal: Value(order.subtotal),
                tax: Value(order.tax),
                total: Value(order.total),
                createdAt: Value(order.createdAt),
                estimatedTime: Value(order.estimatedTime),
                specialInstructions: Value(order.specialInstructions),
              ),
              mode: InsertMode.insertOrReplace,
            );

        for (final item in order.items) {
          await _db.into(_db.dbOrderItems).insert(
                DbOrderItemsCompanion.insert(
                  orderId: order.id,
                  name: item.name,
                  quantity: item.quantity,
                  price: item.price,
                  modifiersJson: Value(
                    item.modifiers == null
                        ? null
                        : jsonEncode(item.modifiers),
                  ),
                  instructions: Value(item.instructions),
                ),
              );
        }
      }
    });
  }

  /// Insert or replace a single order (and its items) without clearing
  /// existing history. This is used for locally-created offline orders.
  Future<void> insertLocalOrder(OrderEntity order) async {
    await _db.transaction(() async {
      // Upsert main order row
      await _db.into(_db.dbOrders).insert(
            DbOrdersCompanion(
              id: Value(order.id),
              queueNumber: Value(order.queueNumber),
              channel: Value(order.channel.name),
              orderType: Value(order.orderType.name),
              paymentStatus: Value(order.paymentStatus.name),
              status: Value(order.status.name),
              customerName: Value(order.customerName),
              customerPhone: Value(order.customerPhone),
              subtotal: Value(order.subtotal),
              tax: Value(order.tax),
              total: Value(order.total),
              createdAt: Value(order.createdAt),
              estimatedTime: Value(order.estimatedTime),
              specialInstructions: Value(order.specialInstructions),
            ),
            mode: InsertMode.insertOrReplace,
          );

      // Replace items for this order id
      await (_db.delete(_db.dbOrderItems)
            ..where((tbl) => tbl.orderId.equals(order.id)))
          .go();

      for (final item in order.items) {
        await _db.into(_db.dbOrderItems).insert(
              DbOrderItemsCompanion.insert(
                orderId: order.id,
                name: item.name,
                quantity: item.quantity,
                price: item.price,
                modifiersJson: Value(
                  item.modifiers == null ? null : jsonEncode(item.modifiers),
                ),
                instructions: Value(item.instructions),
              ),
            );
      }
    });
  }

  /// Returns all orders with their items from local storage.
  Future<List<OrderEntity>> getOrdersWithItems() async {
    final orderRows = await _db.select(_db.dbOrders).get();
    final itemRows = await _db.select(_db.dbOrderItems).get();

    final itemsByOrderId = <String, List<DbOrderItem>>{};
    for (final row in itemRows) {
      itemsByOrderId.putIfAbsent(row.orderId, () => []).add(row);
    }

    return orderRows.map((row) {
      final itemRowsForOrder = itemsByOrderId[row.id] ?? const <DbOrderItem>[];
      final items = itemRowsForOrder.map(_mapItemRowToEntity).toList();
      return _mapOrderRowToEntity(row, items);
    }).toList();
  }

  OrderEntity _mapOrderRowToEntity(
    DbOrder row,
    List<OrderItemEntity> items,
  ) {
    return OrderEntity(
      id: row.id,
      queueNumber: row.queueNumber,
      channel: _parseChannel(row.channel),
      orderType: _parseOrderType(row.orderType),
      paymentStatus: _parsePaymentStatus(row.paymentStatus),
      status: _parseOrderStatus(row.status),
      customerName: row.customerName,
      customerPhone: row.customerPhone,
      items: items,
      subtotal: row.subtotal,
      tax: row.tax,
      total: row.total,
      createdAt: row.createdAt,
      estimatedTime: row.estimatedTime,
      specialInstructions: row.specialInstructions,
      displayStatus: null,
    );
  }

  OrderItemEntity _mapItemRowToEntity(DbOrderItem row) {
    final modifiers = row.modifiersJson == null
        ? null
        : (jsonDecode(row.modifiersJson!) as List<dynamic>)
            .whereType<String>()
            .toList();
    return OrderItemEntity(
      name: row.name,
      quantity: row.quantity,
      price: row.price,
      modifiers: modifiers,
      instructions: row.instructions,
    );
  }

  OrderChannel _parseChannel(String value) {
    return OrderChannel.values.firstWhere(
      (c) => c.name == value,
      orElse: () => OrderChannel.dinein,
    );
  }

  OrderType _parseOrderType(String value) {
    return OrderType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => OrderType.dinein,
    );
  }

  PaymentStatus _parsePaymentStatus(String value) {
    return PaymentStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }

  OrderStatus _parseOrderStatus(String value) {
    return OrderStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => OrderStatus.active,
    );
  }
}

