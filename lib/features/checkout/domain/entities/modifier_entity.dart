import 'package:equatable/equatable.dart';

class ModifierEntity extends Equatable {
  final String name;
  final double price;

  const ModifierEntity({
    required this.name,
    required this.price,
  });

  @override
  List<Object?> get props => [name, price];
}
