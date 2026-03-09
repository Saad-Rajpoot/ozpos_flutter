import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/single_vendor_menu_entity.dart';

/// Represents a logical section of items that belong to a single concrete
/// menu (e.g. "Bankstown Menu", "Test Musab Menu").
class MenuSection {
  final String? menuId;
  final MenuVariantHeader? variant;
  final List<MenuItemEntity> items;

  const MenuSection({
    required this.menuId,
    required this.variant,
    required this.items,
  });
}

