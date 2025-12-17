import 'package:equatable/equatable.dart';

import '../../domain/entities/customer_display_cart_item_entity.dart';

class CustomerDisplayCartItemModel extends Equatable {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final List<String> modifiers;

  const CustomerDisplayCartItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.modifiers = const [],
  });

  factory CustomerDisplayCartItemModel.fromJson(Map<String, dynamic> json) {
    return CustomerDisplayCartItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      modifiers:
          (json['modifiers'] as List<dynamic>?)?.whereType<String>().toList() ??
              const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'modifiers': modifiers,
    };
  }

  CustomerDisplayCartItemEntity toEntity() {
    return CustomerDisplayCartItemEntity(
      id: id,
      name: name,
      price: price,
      quantity: quantity,
      modifiers: modifiers,
    );
  }

  factory CustomerDisplayCartItemModel.fromEntity(
      CustomerDisplayCartItemEntity entity) {
    return CustomerDisplayCartItemModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      quantity: entity.quantity,
      modifiers: List<String>.from(entity.modifiers),
    );
  }

  @override
  List<Object?> get props => [id, name, price, quantity, modifiers];
}
