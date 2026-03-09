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
  /// Identifier of the parent menu this category belongs to (when available).
  /// This matches `MenuVariantHeader.id` for single-vendor menus so the UI can
  /// group items by menu and update the header while scrolling.
  final String? menuId;

  const MenuCategoryEntity({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.menuId,
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
        menuId,
      ];
}
