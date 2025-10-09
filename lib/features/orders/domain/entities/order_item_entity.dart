import 'package:equatable/equatable.dart';

/// Order item entity
class OrderItemEntity extends Equatable {
  final String name;
  final int quantity;
  final double price;
  final List<String>? modifiers;

  const OrderItemEntity({
    required this.name,
    required this.quantity,
    required this.price,
    this.modifiers,
  });

  @override
  List<Object?> get props => [name, quantity, price, modifiers];
}
