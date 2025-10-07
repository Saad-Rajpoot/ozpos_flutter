import '../../../menu/domain/entities/menu_item_edit_entity.dart';

/// System badges that come pre-configured
/// Matches the React prototype badge system
const List<BadgeEntity> systemBadges = [
  BadgeEntity(
    id: 'vegetarian',
    label: 'Vegetarian',
    color: '#10B981',
    icon: '🌱',
    isSystem: true,
  ),
  BadgeEntity(
    id: 'vegan',
    label: 'Vegan',
    color: '#059669',
    icon: '🥬',
    isSystem: true,
  ),
  BadgeEntity(
    id: 'spicy',
    label: 'Spicy',
    color: '#EF4444',
    icon: '🌶️',
    isSystem: true,
  ),
  BadgeEntity(
    id: 'popular',
    label: 'Popular',
    color: '#F59E0B',
    icon: '⭐',
    isSystem: true,
  ),
  BadgeEntity(
    id: 'gluten-free',
    label: 'Gluten-Free',
    color: '#8B5CF6',
    icon: '🌾',
    isSystem: true,
  ),
  BadgeEntity(
    id: 'halal',
    label: 'Halal',
    color: '#10B981',
    icon: '🕌',
    isSystem: true,
  ),
  BadgeEntity(
    id: 'limited-time',
    label: 'Limited Time',
    color: '#DC2626',
    icon: '⏰',
    isSystem: true,
  ),
  BadgeEntity(
    id: 'new',
    label: 'New',
    color: '#3B82F6',
    icon: '✨',
    isSystem: true,
  ),
  BadgeEntity(
    id: 'chef-special',
    label: "Chef's Special",
    color: '#EC4899',
    icon: '👨‍🍳',
    isSystem: true,
  ),
  BadgeEntity(
    id: 'healthy',
    label: 'Healthy',
    color: '#14B8A6',
    icon: '💪',
    isSystem: true,
  ),
];

/// Mock menu items for upsell/related item selection
class MockMenuItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String? image;

  const MockMenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.image,
  });
}

const List<MockMenuItem> mockMenuItemsForSelection = [
  MockMenuItem(
    id: 'item-1',
    name: 'French Fries',
    category: 'Sides',
    price: 3.99,
  ),
  MockMenuItem(
    id: 'item-2',
    name: 'Onion Rings',
    category: 'Sides',
    price: 4.99,
  ),
  MockMenuItem(
    id: 'item-3',
    name: 'Soft Drink',
    category: 'Beverages',
    price: 2.49,
  ),
  MockMenuItem(
    id: 'item-4',
    name: 'Milkshake',
    category: 'Beverages',
    price: 5.49,
  ),
  MockMenuItem(
    id: 'item-5',
    name: 'Caesar Salad',
    category: 'Salads',
    price: 6.99,
  ),
  MockMenuItem(
    id: 'item-6',
    name: 'Chicken Wings',
    category: 'Appetizers',
    price: 8.99,
  ),
  MockMenuItem(
    id: 'item-7',
    name: 'Cheesecake',
    category: 'Desserts',
    price: 5.99,
  ),
  MockMenuItem(
    id: 'item-8',
    name: 'Ice Cream',
    category: 'Desserts',
    price: 3.99,
  ),
];
