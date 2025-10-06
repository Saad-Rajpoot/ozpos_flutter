import 'package:equatable/equatable.dart';

/// Combo option entity for "Make it a Combo" upsells
class ComboOptionEntity extends Equatable {
  final String id;
  final String name; // e.g., "Regular Combo (Fries + Drink)"
  final String description;
  final double priceDelta; // +$6.50
  
  const ComboOptionEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.priceDelta,
  });

  @override
  List<Object?> get props => [id, name, description, priceDelta];
}
