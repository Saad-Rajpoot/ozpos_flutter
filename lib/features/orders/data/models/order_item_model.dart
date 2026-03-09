import 'package:equatable/equatable.dart';
import '../../domain/entities/order_item_entity.dart';

/// Model class for OrderItem JSON serialization/deserialization
class OrderItemModel extends Equatable {
  final String name;
  final int quantity;
  final double price;
  final List<String>? modifiers;
  final String? instructions;

  const OrderItemModel({
    required this.name,
    required this.quantity,
    required this.price,
    this.modifiers,
    this.instructions,
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
      instructions: json['instructions'] as String?,
    );
  }

  /// Parse order item from history API format
  factory OrderItemModel.fromHistoryItemJson(Map<String, dynamic> json) {
    final quantityRaw = json['quantity'];
    final quantity = quantityRaw is int
        ? quantityRaw
        : (double.tryParse(quantityRaw?.toString() ?? '1') ?? 1).round();
    final totalCents = (json['total_price_cents'] as num?)?.toDouble() ?? 0.0;
    final price = totalCents / 100;
    final options = json['options'] as List<dynamic>?;
    final modifiers = options
        ?.map((o) {
          if (o is! Map) return '';
          final group = (o['group_name'] ?? '').toString().trim();
          final name = (o['name'] ?? '').toString().trim();
          if (name.isEmpty) return group.isNotEmpty ? group : '';
          return group.isEmpty ? name : '$group: $name';
        })
        .where((s) => s.isNotEmpty)
        .toList();
    final meta = json['meta'] as Map<String, dynamic>?;
    final specialInstructions = meta?['special_instructions'] as String?;
    final customerNotes = json['customer_notes'] as String?;
    final kitchenNotes = json['kitchen_notes'] as String?;
    final instructions = (specialInstructions ?? customerNotes ?? kitchenNotes)
        ?.trim();
    return OrderItemModel(
      name: (json['name'] as String?) ?? '',
      quantity: quantity,
      price: price,
      modifiers: modifiers != null && modifiers.isNotEmpty ? modifiers : null,
      instructions: instructions != null && instructions.isNotEmpty ? instructions : null,
    );
  }

  /// Convert OrderItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'modifiers': modifiers,
      'instructions': instructions,
    };
  }

  /// Convert OrderItemModel to OrderItemEntity
  OrderItemEntity toEntity() {
    return OrderItemEntity(
      name: name,
      quantity: quantity,
      price: price,
      modifiers: modifiers,
      instructions: instructions,
    );
  }

  /// Create OrderItemModel from OrderItemEntity
  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      name: entity.name,
      quantity: entity.quantity,
      price: entity.price,
      modifiers: entity.modifiers,
      instructions: entity.instructions,
    );
  }

  @override
  List<Object?> get props => [name, quantity, price, modifiers, instructions];
}
