import 'package:equatable/equatable.dart';
import '../../domain/entities/order_item_entity.dart';

/// Model class for OrderItem JSON serialization/deserialization
class OrderItemModel extends Equatable {
  final String name;
  final int quantity;
  final double price;
  final List<String>? modifiers;

  const OrderItemModel({
    required this.name,
    required this.quantity,
    required this.price,
    this.modifiers,
  });

  /// Convert JSON to OrderItemModel
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      modifiers: json['modifiers'] != null
          ? List<String>.from(json['modifiers'] as List<dynamic>)
          : null,
    );
  }

  /// Convert OrderItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'modifiers': modifiers,
    };
  }

  /// Convert OrderItemModel to OrderItemEntity
  OrderItemEntity toEntity() {
    return OrderItemEntity(
      name: name,
      quantity: quantity,
      price: price,
      modifiers: modifiers,
    );
  }

  /// Create OrderItemModel from OrderItemEntity
  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      name: entity.name,
      quantity: entity.quantity,
      price: entity.price,
      modifiers: entity.modifiers,
    );
  }

  @override
  List<Object?> get props => [name, quantity, price, modifiers];
}
