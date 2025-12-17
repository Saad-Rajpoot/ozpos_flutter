class DebugMenuItem {
  const DebugMenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.sizes,
    required this.modifiers,
  });

  final String id;
  final String name;
  final double price;
  final String category;
  final List<String> sizes;
  final List<DebugModifier> modifiers;
}

class DebugModifier {
  const DebugModifier({required this.id, required this.name});

  final String id;
  final String name;
}

/// Mock menu items for testing combo builder
class DebugComboMockData {
  static final List<DebugMenuItem> mockMenuItems = [
    DebugMenuItem(
      id: 'burger-1',
      name: 'Classic Burger',
      price: 12.99,
      category: 'burgers',
      sizes: const ['Small', 'Medium', 'Large'],
      modifiers: const [
        DebugModifier(id: 'mod-1', name: 'Extra Cheese'),
        DebugModifier(id: 'mod-2', name: 'Extra Meat'),
        DebugModifier(id: 'mod-3', name: 'No Pickles'),
        DebugModifier(id: 'mod-4', name: 'Extra Bacon'),
      ],
    ),
    DebugMenuItem(
      id: 'pizza-1',
      name: 'Margherita Pizza',
      price: 18.0,
      category: 'pizzas',
      sizes: const ['Small', 'Medium', 'Large', 'X-Large'],
      modifiers: const [
        DebugModifier(id: 'mod-5', name: 'Extra Cheese'),
        DebugModifier(id: 'mod-6', name: 'Olives'),
        DebugModifier(id: 'mod-7', name: 'Mushrooms'),
      ],
    ),
    DebugMenuItem(
      id: 'fries-1',
      name: 'French Fries',
      price: 5.0,
      category: 'sides',
      sizes: const ['Small', 'Medium', 'Large'],
      modifiers: const [],
    ),
    DebugMenuItem(
      id: 'drink-1',
      name: 'Coca-Cola',
      price: 3.5,
      category: 'beverages',
      sizes: const ['Small', 'Medium', 'Large'],
      modifiers: const [],
    ),
    DebugMenuItem(
      id: 'drink-2',
      name: 'Sprite',
      price: 3.5,
      category: 'beverages',
      sizes: const ['Small', 'Medium', 'Large'],
      modifiers: const [],
    ),
    DebugMenuItem(
      id: 'dessert-1',
      name: 'Chocolate Cake',
      price: 6.5,
      category: 'desserts',
      sizes: const [],
      modifiers: const [
        DebugModifier(id: 'mod-8', name: 'Extra Cream'),
        DebugModifier(id: 'mod-9', name: 'Ice Cream'),
      ],
    ),
    DebugMenuItem(
      id: 'dessert-2',
      name: 'Apple Pie',
      price: 5.5,
      category: 'desserts',
      sizes: const [],
      modifiers: const [
        DebugModifier(id: 'mod-10', name: 'Ice Cream'),
      ],
    ),
  ];

  static const List<String> categories = [
    'burgers',
    'pizzas',
    'sides',
    'beverages',
    'desserts',
  ];
}
