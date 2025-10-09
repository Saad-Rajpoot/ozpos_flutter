import 'package:equatable/equatable.dart';
import '../../domain/entities/delivery_entities.dart';

/// Model class for Order JSON serialization/deserialization
class OrderModel extends Equatable {
  final String id;
  final String orderNumber;
  final String channel;
  final String status;
  final String customerName;
  final String address;
  final List<String> items;
  final int pickupEtaMinutes;
  final int deliveryEtaMinutes;
  final String? assignedDriverId;
  final double pickupLatitude;
  final double pickupLongitude;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final int createdAtMinutes;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.channel,
    required this.status,
    required this.customerName,
    required this.address,
    required this.items,
    required this.pickupEtaMinutes,
    required this.deliveryEtaMinutes,
    this.assignedDriverId,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.createdAtMinutes,
  });

  /// Convert JSON to OrderModel
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      channel: json['channel'] as String,
      status: json['status'] as String,
      customerName: json['customerName'] as String,
      address: json['address'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      pickupEtaMinutes: json['pickupEtaMinutes'] as int,
      deliveryEtaMinutes: json['deliveryEtaMinutes'] as int,
      assignedDriverId: json['assignedDriverId'] as String?,
      pickupLatitude: (json['pickupLatitude'] as num).toDouble(),
      pickupLongitude: (json['pickupLongitude'] as num).toDouble(),
      deliveryLatitude: (json['deliveryLatitude'] as num).toDouble(),
      deliveryLongitude: (json['deliveryLongitude'] as num).toDouble(),
      createdAtMinutes: json['createdAtMinutes'] as int,
    );
  }

  /// Convert OrderModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'channel': channel,
      'status': status,
      'customerName': customerName,
      'address': address,
      'items': items,
      'pickupEtaMinutes': pickupEtaMinutes,
      'deliveryEtaMinutes': deliveryEtaMinutes,
      'assignedDriverId': assignedDriverId,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'createdAtMinutes': createdAtMinutes,
    };
  }

  /// Convert OrderModel to Order entity
  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      orderNumber: orderNumber,
      channel: channel,
      status: status,
      customerName: customerName,
      address: address,
      items: items,
      pickupEtaMinutes: pickupEtaMinutes,
      deliveryEtaMinutes: deliveryEtaMinutes,
      assignedDriverId: assignedDriverId,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      createdAtMinutes: createdAtMinutes,
    );
  }

  /// Create OrderModel from Order entity
  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      channel: entity.channel,
      status: entity.status,
      customerName: entity.customerName,
      address: entity.address,
      items: entity.items,
      pickupEtaMinutes: entity.pickupEtaMinutes,
      deliveryEtaMinutes: entity.deliveryEtaMinutes,
      assignedDriverId: entity.assignedDriverId,
      pickupLatitude: entity.pickupLatitude,
      pickupLongitude: entity.pickupLongitude,
      deliveryLatitude: entity.deliveryLatitude,
      deliveryLongitude: entity.deliveryLongitude,
      createdAtMinutes: entity.createdAtMinutes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    channel,
    status,
    customerName,
    address,
    items,
    pickupEtaMinutes,
    deliveryEtaMinutes,
    assignedDriverId,
    pickupLatitude,
    pickupLongitude,
    deliveryLatitude,
    deliveryLongitude,
    createdAtMinutes,
  ];
}
