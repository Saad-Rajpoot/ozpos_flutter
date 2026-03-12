import 'package:equatable/equatable.dart';
import 'order_item_entity.dart';

/// Order status matching React implementation
enum OrderStatus { active, completed, cancelled }

/// Payment status
enum PaymentStatus { paid, unpaid }

/// Channel/Platform types
enum OrderChannel {
  ubereats,
  doordash,
  menulog,
  website,
  app,
  qr,
  dinein,
  takeaway,
  delivery,
}

/// Order type (service method)
enum OrderType { delivery, takeaway, dinein }

/// Main order entity
class OrderEntity extends Equatable {
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
  /// Nullable because older/offline records may not have this populated.
  final String? paymentMethod;
  final String customerName;
  final String? customerPhone;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double tax;
  final double total;
  final DateTime createdAt;
  final DateTime estimatedTime;
  final String? specialInstructions;
  /// Table number for dine-in orders (e.g. "7"). From history API `table_number`.
  final String? tableNumber;
  /// Raw delivery_status from history API (e.g. NOT_APPLICABLE, OUT_FOR_DELIVERY).
  final String? deliveryStatus;
  /// Optional human-readable status coming from the backend
  /// (e.g. ACCEPTED, PREPARING, READY). When present, UI components
  /// should prefer this over coarse-grained enum labels.
  final String? displayStatus;
  /// Raw preparation_status from history API (e.g. PENDING, PREPARING).
  final String? preparationStatus;

  const OrderEntity({
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

  OrderEntity copyWith({
    String? id,
    String? queueNumber,
    String? orderNumber,
    String? referenceNo,
    String? source,
    OrderChannel? channel,
    OrderType? orderType,
    String? serviceType,
    PaymentStatus? paymentStatus,
    OrderStatus? status,
    String? paymentMethod,
    String? customerName,
    String? customerPhone,
    List<OrderItemEntity>? items,
    double? subtotal,
    double? tax,
    double? total,
    DateTime? createdAt,
    DateTime? estimatedTime,
    String? specialInstructions,
    String? tableNumber,
    String? deliveryStatus,
    String? displayStatus,
    String? preparationStatus,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      queueNumber: queueNumber ?? this.queueNumber,
      orderNumber: orderNumber ?? this.orderNumber,
      referenceNo: referenceNo ?? this.referenceNo,
      source: source ?? this.source,
      channel: channel ?? this.channel,
      orderType: orderType ?? this.orderType,
      serviceType: serviceType ?? this.serviceType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      tableNumber: tableNumber ?? this.tableNumber,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      displayStatus: displayStatus ?? this.displayStatus,
      preparationStatus: preparationStatus ?? this.preparationStatus,
    );
  }
}

/// Extension methods for channel
extension OrderChannelX on OrderChannel {
  String get name {
    switch (this) {
      case OrderChannel.ubereats:
        return 'UberEats';
      case OrderChannel.doordash:
        return 'DoorDash';
      case OrderChannel.menulog:
        return 'Menulog';
      case OrderChannel.website:
        return 'Website';
      case OrderChannel.app:
        return 'Mobile App';
      case OrderChannel.qr:
        return 'QR Order';
      case OrderChannel.dinein:
        return 'Dine-In';
      case OrderChannel.takeaway:
        return 'Pickup';
      case OrderChannel.delivery:
        return 'Delivery';
    }
  }

  String get emoji {
    switch (this) {
      case OrderChannel.ubereats:
        return '🍕';
      case OrderChannel.doordash:
        return '🚪';
      case OrderChannel.menulog:
        return '📱';
      case OrderChannel.website:
        return '🌐';
      case OrderChannel.app:
        return '📱';
      case OrderChannel.qr:
        return '📲';
      case OrderChannel.dinein:
        return '🍽️';
      case OrderChannel.takeaway:
        return '🥡';
      case OrderChannel.delivery:
        return '🚚';
    }
  }
}
