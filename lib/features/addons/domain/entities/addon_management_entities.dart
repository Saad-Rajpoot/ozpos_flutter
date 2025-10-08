import 'package:equatable/equatable.dart';

/// Simple addon category that matches JSON structure
class AddonCategory extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<AddonItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AddonCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  AddonCategory copyWith({
    String? id,
    String? name,
    String? description,
    List<AddonItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddonCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    items,
    createdAt,
    updatedAt,
  ];
}

/// Simple addon item that matches JSON structure
class AddonItem extends Equatable {
  final String id;
  final String name;
  final double basePriceDelta;

  const AddonItem({
    required this.id,
    required this.name,
    required this.basePriceDelta,
  });

  @override
  List<Object?> get props => [id, name, basePriceDelta];
}
