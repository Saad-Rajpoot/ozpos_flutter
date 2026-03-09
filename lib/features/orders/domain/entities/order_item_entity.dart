import 'package:equatable/equatable.dart';

/// Order item entity
class OrderItemEntity extends Equatable {
  final String name;
  final int quantity;
  final double price;
  /// Modifier lines in "Category: Selection" format (e.g. "Choose Size: Small")
  final List<String>? modifiers;
  /// Customer or kitchen instructions for this item
  final String? instructions;

  const OrderItemEntity({
    required this.name,
    required this.quantity,
    required this.price,
    this.modifiers,
    this.instructions,
  });

  @override
  List<Object?> get props => [name, quantity, price, modifiers, instructions];
}
