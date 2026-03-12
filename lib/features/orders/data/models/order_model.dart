import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';

/// Model class for Order JSON serialization/deserialization
class OrderModel extends Equatable {
  final String id;
  final String queueNumber;
  /// Raw order number from history API (e.g. "20260310-0014").
  final String? orderNumber;
  /// Reference number from history API (e.g. "REF-XYZ").
  final String? referenceNo;
  /// Raw source from history API (e.g. POS, ONLINE, UBEREATS).
  final String? source;
  final OrderChannel channel;
  final OrderType orderType;
  /// Raw service_type from history API (e.g. ONLINE_DELIVERY, PICKUP).
  final String? serviceType;
  final PaymentStatus paymentStatus;
  final OrderStatus status;
  /// Raw payment method from backend history (e.g. 'cash', 'pay_later').
  final String? paymentMethod;
  final String customerName;
  final String? customerPhone;
  final List<OrderItemModel> items;
  final double subtotal;
  final double tax;
  final double total;
  final DateTime createdAt;
  final DateTime estimatedTime;
  final String? specialInstructions;
  /// Table number for dine-in orders, from history API `table_number`.
  final String? tableNumber;
  /// Raw delivery_status from history API.
  final String? deliveryStatus;
  /// Optional human-readable status coming from the backend
  /// (e.g. ACCEPTED, PREPARING, READY). When present, UI components
  /// should prefer this over coarse-grained enum labels.
  final String? displayStatus;
  /// Raw preparation_status from history API.
  final String? preparationStatus;

  const OrderModel({
    required this.id,
    required this.queueNumber,
    this.orderNumber,
    this.referenceNo,
    this.source,
    required this.channel,
    required this.orderType,
    this.serviceType,
    required this.paymentStatus,
    required this.status,
    this.paymentMethod,
    required this.customerName,
    this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.createdAt,
    required this.estimatedTime,
    this.specialInstructions,
    this.tableNumber,
    this.deliveryStatus,
    this.displayStatus,
    this.preparationStatus,
  });

  /// Parse order from history API format (GET /api/pos/orders/history)
  factory OrderModel.fromHistoryApi(Map<String, dynamic> json) {
    final sourceRaw = json['source'] as String? ?? 'POS';
    final sourceUpper = sourceRaw.toUpperCase();
    final serviceType =
        (json['service_type'] as String?)?.toUpperCase() ?? 'PICKUP';
    OrderChannel channel;
    if (sourceUpper == 'POS') {
      // For POS orders, channel reflects fulfillment (so filter/card match service_type)
      switch (serviceType) {
        case 'DELIVERY':
          channel = OrderChannel.delivery;
          break;
        case 'DINE_IN':
        case 'DINEIN':
          channel = OrderChannel.dinein;
          break;
        case 'PICKUP':
        default:
          channel = OrderChannel.takeaway;
          break;
      }
    } else {
      // For ONLINE/3rd‑party orders, channel represents the platform/source.
      switch (sourceUpper) {
        case 'UBEREATS':
          channel = OrderChannel.ubereats;
          break;
        case 'DOORDASH':
          channel = OrderChannel.doordash;
          break;
        case 'MENULOG':
          channel = OrderChannel.menulog;
          break;
        case 'WEBSITE':
          channel = OrderChannel.website;
          break;
        case 'APP':
          channel = OrderChannel.app;
          break;
        case 'QR':
          channel = OrderChannel.qr;
          break;
        case 'ONLINE':
          // Treat generic ONLINE orders as Delivery channel so the chip
          // matches the actual fulfillment type instead of showing Dine‑In.
          channel = OrderChannel.delivery;
          break;
        default:
          channel = OrderChannel.dinein;
      }
    }
    final orderType = switch (serviceType) {
      'DELIVERY' || 'ONLINE_DELIVERY' => OrderType.delivery,
      'DINE_IN' || 'DINEIN' => OrderType.dinein,
      _ => OrderType.takeaway,
    };
    final paymentStatusRaw =
        (json['payment_status'] as String?)?.toUpperCase() ?? 'PENDING';
    final paymentStatus =
        paymentStatusRaw == 'PAID' ? PaymentStatus.paid : PaymentStatus.unpaid;
    final statusRaw = (json['status'] as String?)?.toUpperCase() ?? 'CREATED';
    final preparationStatusRaw =
        (json['preparation_status'] as String?)?.toUpperCase();
    final deliveryStatusRaw =
        (json['delivery_status'] as String?)?.toUpperCase();
    // Map high-level status used for tabs/filters.
    // If preparation_status is DELIVERED we want the order to appear under
    // the Completed section, even if the coarse status is still CREATED.
    final status = switch (statusRaw) {
      'COMPLETED' => OrderStatus.completed,
      'CANCELLED' || 'CANCELED' => OrderStatus.cancelled,
      _ => preparationStatusRaw == 'DELIVERED'
          ? OrderStatus.completed
          : OrderStatus.active,
    };
    final paymentMethod = json['payment_method'] as String?;
    final customerSnapshot =
        json['customer_snapshot'] as Map<String, dynamic>? ?? {};
    final customerName =
        (customerSnapshot['name'] as String?)?.trim() ?? '';
    final customerPhone = customerSnapshot['phone'] as String?;
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson
        .map((e) => OrderItemModel.fromHistoryItemJson(
              e is Map<String, dynamic> ? e : <String, dynamic>{},
            ))
        .toList();
    final subtotalCents = (json['subtotal_cents'] as num?)?.toDouble() ?? 0.0;
    final taxCents = (json['tax_cents'] as num?)?.toDouble() ?? 0.0;
    final totalCents = (json['total_cents'] as num?)?.toDouble() ?? 0.0;
    final placedAt = json['placed_at_utc'] ?? json['created_at'];
    final createdAt = placedAt != null
        ? DateTime.tryParse(placedAt.toString()) ?? DateTime.now()
        : DateTime.now();
    final estimatedAt = json['estimated_ready_at_utc'] ?? json['expected_pickup_at_utc'];
    final estimatedTime = estimatedAt != null
        ? DateTime.tryParse(estimatedAt.toString()) ?? createdAt
        : createdAt;
    final displayIdRaw = json['display_id'] as String?;
    final displayId =
        displayIdRaw?.replaceFirst(RegExp(r'^#'), '').trim() ?? displayIdRaw;
    final orderNumber = json['order_number'] as String?;
    final referenceNo = json['reference_no'] as String?;
    final rawId = json['id']?.toString() ?? '';
    final id = rawId;
    final queueNumber = displayId ?? orderNumber ?? rawId;
    final tableNumberRaw = json['table_number'];
    final tableNumber = tableNumberRaw == null
        ? null
        : tableNumberRaw.toString().trim().isEmpty
            ? null
            : tableNumberRaw.toString().trim();

    // Choose a human-readable status label for UI.
    // We want this to mirror the backend `status` field (e.g. CREATED,
    // COMPLETED, CANCELLED, DELIVERED) so that it matches the web card.
    // The separate `preparationStatus` field is shown independently.
    final displayStatus = statusRaw.isNotEmpty ? statusRaw : null;

    return OrderModel(
      id: id,
      queueNumber: queueNumber,
      orderNumber: orderNumber,
      referenceNo: referenceNo,
      source: sourceRaw,
      channel: channel,
      orderType: orderType,
      serviceType: serviceType,
      paymentStatus: paymentStatus,
      status: status,
      paymentMethod: paymentMethod,
      customerName: customerName,
      customerPhone: customerPhone,
      items: items,
      subtotal: subtotalCents / 100,
      tax: taxCents / 100,
      total: totalCents / 100,
      createdAt: createdAt,
      estimatedTime: estimatedTime,
      specialInstructions: json['notes'] as String?,
      tableNumber: tableNumber,
      deliveryStatus: deliveryStatusRaw,
      displayStatus: displayStatus,
      preparationStatus: preparationStatusRaw,
    );
  }

  /// Convert JSON to OrderModel
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      queueNumber: json['queueNumber'] as String,
      orderNumber: json['orderNumber'] as String?,
      referenceNo: json['referenceNo'] as String?,
      source: json['source'] as String?,
      channel: OrderChannel.values.firstWhere(
        (e) => e.toString().split('.').last == json['channel'],
      ),
      orderType: OrderType.values.firstWhere(
        (e) => e.toString().split('.').last == json['orderType'],
      ),
      serviceType: json['serviceType'] as String?,
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentStatus'],
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      paymentMethod: json['paymentMethod'] as String?,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) => OrderItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          <OrderItemModel>[],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.now().subtract(
        Duration(minutes: json['createdAtMinutes'] ?? 0),
      ),
      estimatedTime: DateTime.now().add(
        Duration(minutes: json['estimatedTimeMinutes'] ?? 0),
      ),
      specialInstructions: json['specialInstructions'] as String?,
      tableNumber: json['tableNumber'] as String?,
      deliveryStatus: json['deliveryStatus'] as String?,
      displayStatus: json['displayStatus'] as String?,
    );
  }

  /// Convert OrderModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queueNumber': queueNumber,
      'orderNumber': orderNumber,
      'referenceNo': referenceNo,
      'source': source,
      'channel': channel.toString().split('.').last,
      'orderType': orderType.toString().split('.').last,
      'serviceType': serviceType,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'createdAtMinutes': DateTime.now().difference(createdAt).inMinutes,
      'estimatedTimeMinutes': estimatedTime
          .difference(DateTime.now())
          .inMinutes,
      'specialInstructions': specialInstructions,
      'tableNumber': tableNumber,
      'deliveryStatus': deliveryStatus,
      'displayStatus': displayStatus,
    };
  }

  /// Convert OrderModel to OrderEntity
  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      queueNumber: queueNumber,
      orderNumber: orderNumber,
      referenceNo: referenceNo,
      source: source,
      channel: channel,
      orderType: orderType,
      serviceType: serviceType,
      paymentStatus: paymentStatus,
      status: status,
      paymentMethod: paymentMethod,
      customerName: customerName,
      customerPhone: customerPhone,
      items: items.map((item) => item.toEntity()).toList(),
      subtotal: subtotal,
      tax: tax,
      total: total,
      createdAt: createdAt,
      estimatedTime: estimatedTime,
      specialInstructions: specialInstructions,
      tableNumber: tableNumber,
      deliveryStatus: deliveryStatus,
      displayStatus: displayStatus,
      preparationStatus: preparationStatus,
    );
  }

  /// Create OrderModel from OrderEntity
  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      queueNumber: entity.queueNumber,
      orderNumber: entity.orderNumber,
      referenceNo: entity.referenceNo,
      source: entity.source,
      channel: entity.channel,
      orderType: entity.orderType,
      serviceType: entity.serviceType,
      paymentStatus: entity.paymentStatus,
      status: entity.status,
      paymentMethod: entity.paymentMethod,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      items: entity.items
          .map((item) => OrderItemModel.fromEntity(item))
          .toList(),
      subtotal: entity.subtotal,
      tax: entity.tax,
      total: entity.total,
      createdAt: entity.createdAt,
      estimatedTime: entity.estimatedTime,
      specialInstructions: entity.specialInstructions,
      tableNumber: entity.tableNumber,
      deliveryStatus: entity.deliveryStatus,
      displayStatus: entity.displayStatus,
      preparationStatus: entity.preparationStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        queueNumber,
        orderNumber,
        referenceNo,
        source,
        channel,
        orderType,
        serviceType,
        paymentStatus,
        status,
        paymentMethod,
        customerName,
        customerPhone,
        items,
        subtotal,
        tax,
        total,
        createdAt,
        estimatedTime,
        specialInstructions,
        tableNumber,
        deliveryStatus,
        displayStatus,
        preparationStatus,
      ];
}
