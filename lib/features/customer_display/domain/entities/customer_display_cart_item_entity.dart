import 'package:equatable/equatable.dart';

/// Entity representing a single line item in the customer display cart
class CustomerDisplayCartItemEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final List<String> modifiers;

  const CustomerDisplayCartItemEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.modifiers = const [],
  });

  double get lineTotal => price * quantity;

  @override
  List<Object?> get props => [id, name, price, quantity, modifiers];
}
