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
  final String customerName;
  final String? customerPhone;
  final List<OrderItemModel> items;
  final double subtotal;
  final double tax;
  final double total;
  final DateTime createdAt;
  final DateTime estimatedTime;
  final String? specialInstructions;

  const OrderModel({
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
      customerName: customerName,
      customerPhone: customerPhone,
      items: items.map((item) => item.toEntity()).toList(),
      subtotal: subtotal,
      tax: tax,
      total: total,
      createdAt: createdAt,
      estimatedTime: estimatedTime,
      specialInstructions: specialInstructions,
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
}
