import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';

/// Model class for Order JSON serialization/deserialization
class OrderModel extends Equatable {
  final String id;
  final String queueNumber;
  final OrderChannel channel;
  final OrderType orderType;
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
  /// Optional human-readable status coming from the backend
  /// (e.g. ACCEPTED, PREPARING, READY). When present, UI components
  /// should prefer this over coarse-grained enum labels.
  final String? displayStatus;

  const OrderModel({
    required this.id,
    required this.queueNumber,
    required this.channel,
    required this.orderType,
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
    this.displayStatus,
  });

  /// Parse order from history API format (GET /api/pos/orders/history)
  factory OrderModel.fromHistoryApi(Map<String, dynamic> json) {
    final source = (json['source'] as String?)?.toUpperCase() ?? 'POS';
    final serviceType =
        (json['service_type'] as String?)?.toUpperCase() ?? 'PICKUP';
    OrderChannel channel;
    if (source == 'POS') {
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
      switch (source) {
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
        default:
          channel = OrderChannel.dinein;
      }
    }
    final orderType = switch (serviceType) {
      'DELIVERY' => OrderType.delivery,
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
    final status = switch (statusRaw) {
      'COMPLETED' => OrderStatus.completed,
      'CANCELLED' || 'CANCELED' => OrderStatus.cancelled,
      _ => OrderStatus.active,
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
    final id = displayId ?? orderNumber ?? (json['id']?.toString() ?? '');
    final queueNumber = displayId ?? orderNumber ?? id;
    final tableNumberRaw = json['table_number'];
    final tableNumber = tableNumberRaw == null
        ? null
        : tableNumberRaw.toString().trim().isEmpty
            ? null
            : tableNumberRaw.toString().trim();

    // Choose a human-readable status label for UI:
    // - cancelled/completed/unpaid are kept as-is
    // - otherwise prefer preparation_status when available
    // - finally fall back to backend status string.
    String? displayStatus;
    if (status == OrderStatus.cancelled) {
      displayStatus = 'CANCELLED';
    } else if (status == OrderStatus.completed) {
      displayStatus = 'COMPLETED';
    } else if (paymentStatus == PaymentStatus.unpaid) {
      displayStatus = 'UNPAID';
    } else if (preparationStatusRaw != null &&
        preparationStatusRaw.isNotEmpty) {
      displayStatus = preparationStatusRaw;
    } else if (statusRaw.isNotEmpty) {
      displayStatus = statusRaw;
    }

    return OrderModel(
      id: id,
      queueNumber: queueNumber,
      channel: channel,
      orderType: orderType,
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
      displayStatus: displayStatus,
    );
  }

  /// Convert JSON to OrderModel
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      queueNumber: json['queueNumber'] as String,
      channel: OrderChannel.values.firstWhere(
        (e) => e.toString().split('.').last == json['channel'],
      ),
      orderType: OrderType.values.firstWhere(
        (e) => e.toString().split('.').last == json['orderType'],
      ),
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
      displayStatus: json['displayStatus'] as String?,
    );
  }

  /// Convert OrderModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queueNumber': queueNumber,
      'channel': channel.toString().split('.').last,
      'orderType': orderType.toString().split('.').last,
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
      'displayStatus': displayStatus,
    };
  }

  /// Convert OrderModel to OrderEntity
  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      queueNumber: queueNumber,
      channel: channel,
      orderType: orderType,
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
      displayStatus: displayStatus,
    );
  }

  /// Create OrderModel from OrderEntity
  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      queueNumber: entity.queueNumber,
      channel: entity.channel,
      orderType: entity.orderType,
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
      displayStatus: entity.displayStatus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    queueNumber,
    channel,
    orderType,
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
    displayStatus,
  ];
}
