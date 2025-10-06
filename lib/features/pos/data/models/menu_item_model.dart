import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/menu_item_entity.dart';

part 'menu_item_model.freezed.dart';
part 'menu_item_model.g.dart';

/// Menu item model
@freezed
class MenuItemModel with _$MenuItemModel {
  const factory MenuItemModel({
    required String id,
    required String categoryId,
    required String name,
    required String description,
    String? image,
    required double basePrice,
    @Default([]) List<String> tags,
  }) = _MenuItemModel;

  const MenuItemModel._();

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

  /// Create model from JSON
  factory MenuItemModel.fromJson(Map<String, dynamic> json) =>
      _$$MenuItemModelImplFromJson(json);

  /// Convert model to JSON
  Map<String, dynamic> toJson() => _$$MenuItemModelImplToJson(this as _$MenuItemModelImpl);
}
