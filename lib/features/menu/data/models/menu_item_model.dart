import '../../domain/entities/menu_item_entity.dart';

/// Menu item model
class MenuItemModel {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String? image;
  final double basePrice;
  final List<String> tags;

  const MenuItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    this.image,
    required this.basePrice,
    this.tags = const [],
  });

  /// Create entity from model
  MenuItemEntity toEntity() {
    return MenuItemEntity(
      id: id,
      categoryId: categoryId,
      name: name,
      description: description,
      image: image,
      basePrice: basePrice,
      tags: tags,
    );
  }

  /// Create model from entity
  factory MenuItemModel.fromEntity(MenuItemEntity entity) {
    return MenuItemModel(
      id: entity.id,
      categoryId: entity.categoryId,
      name: entity.name,
      description: entity.description,
      image: entity.image,
      basePrice: entity.basePrice,
      tags: entity.tags,
    );
  }

  /// Create a copy of this model with some fields replaced
  MenuItemModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    String? image,
    double? basePrice,
    List<String>? tags,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      basePrice: basePrice ?? this.basePrice,
      tags: tags ?? this.tags,
    );
  }

  /// Create model from JSON
  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String?,
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'image': image,
      'base_price': basePrice,
      'tags': tags,
    };
  }

  @override
  String toString() {
    return 'MenuItemModel(id: $id, name: $name, basePrice: $basePrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItemModel &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.name == name &&
        other.description == description &&
        other.image == image &&
        other.basePrice == basePrice &&
        other.tags == tags;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      categoryId,
      name,
      description,
      image,
      basePrice,
      tags,
    );
  }
}
