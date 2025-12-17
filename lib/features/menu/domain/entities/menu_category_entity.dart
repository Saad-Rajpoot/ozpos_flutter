import 'package:equatable/equatable.dart';

/// Menu category entity
class MenuCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuCategoryEntity({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        sortOrder,
        isActive,
        createdAt,
        updatedAt,
      ];
}
