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
}

/// Order type (service method)
enum OrderType { delivery, takeaway, dinein }

/// Main order entity
class OrderEntity extends Equatable {
  final String id;
  final String queueNumber;
  final OrderChannel channel;
  final OrderType orderType;
  final PaymentStatus paymentStatus;
  final OrderStatus status;
  final String customerName;
  final String? customerPhone;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double tax;
  final double total;
  final DateTime createdAt;
  final DateTime estimatedTime;
  final String? specialInstructions;

  const OrderEntity({
    required this.id,
    required this.queueNumber,
    required this.channel,
    required this.orderType,
    required this.paymentStatus,
    required this.status,
    required this.customerName,
    this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.createdAt,
    required this.estimatedTime,
    this.specialInstructions,
  });

  @override
  List<Object?> get props => [
    id,
    queueNumber,
    channel,
    orderType,
    paymentStatus,
    status,
    customerName,
    customerPhone,
    items,
    subtotal,
    tax,
    total,
    createdAt,
    estimatedTime,
    specialInstructions,
  ];

  OrderEntity copyWith({
    String? id,
    String? queueNumber,
    OrderChannel? channel,
    OrderType? orderType,
    PaymentStatus? paymentStatus,
    OrderStatus? status,
    String? customerName,
    String? customerPhone,
    List<OrderItemEntity>? items,
    double? subtotal,
    double? tax,
    double? total,
    DateTime? createdAt,
    DateTime? estimatedTime,
    String? specialInstructions,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      queueNumber: queueNumber ?? this.queueNumber,
      channel: channel ?? this.channel,
      orderType: orderType ?? this.orderType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      specialInstructions: specialInstructions ?? this.specialInstructions,
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
        return 'Takeaway';
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
    }
  }
}
