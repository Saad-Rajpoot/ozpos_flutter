import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'order_model.dart';
import 'checkout_metadata.dart';
import '../../domain/entities/checkout_entity.dart';

// JSON conversion functions
CheckoutData checkoutDataFromJson(String str) =>
    CheckoutData.fromJson(json.decode(str));

String checkoutDataToJson(CheckoutData data) => json.encode(data.toJson());

// Main checkout data wrapper
class CheckoutData extends Equatable {
  final List<OrderModel> orders;
  final CheckoutMetadata metadata;

  const CheckoutData({
    required this.orders,
    required this.metadata,
  });

  factory CheckoutData.fromJson(Map<String, dynamic> json) {
    return CheckoutData(
      orders: List<OrderModel>.from(
        json['orders'].map((x) => OrderModel.fromJson(x)),
      ),
      metadata: CheckoutMetadata.fromJson(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': List<dynamic>.from(orders.map((x) => x.toJson())),
      'metadata': metadata.toJson(),
    };
  }

  @override
  List<Object?> get props => [orders, metadata];

  // Convert to domain entity
  CheckoutEntity toEntity() {
    return CheckoutEntity(
      orders: orders.map((order) => order.toEntity()).toList(),
      metadata: metadata.toEntity(),
    );
  }

  // Create from domain entity
  factory CheckoutData.fromEntity(CheckoutEntity entity) {
    return CheckoutData(
      orders: entity.orders.map((order) => OrderModel.fromEntity(order)).toList(),
      metadata: CheckoutMetadata.fromEntity(entity.metadata),
    );
  }
}
