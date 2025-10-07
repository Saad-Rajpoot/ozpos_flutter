import '../../menu/domain/entities/menu_item_entity.dart';
import '../domain/entities/modifier_group_entity.dart';
import '../domain/entities/modifier_option_entity.dart';
import '../domain/entities/combo_option_entity.dart';
import '../domain/entities/table_entity.dart';

/// Seed data for development and testing
class SeedData {
  // ============================================================================
  // MENU ITEMS WITH MODIFIERS & COMBOS
  // ============================================================================

  static final List<MenuItemEntity> menuItems = [
    // 1. CLASSIC BURGER
    MenuItemEntity(
      id: 'item-1',
      categoryId: 'burgers',
      name: 'Classic Burger',
      description:
          'Juicy beef patty with fresh lettuce, tomato, and signature sauce.',
      image:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      basePrice: 12.99,
      tags: ['Popular'],
      modifierGroups: [
        ModifierGroupEntity(
          id: 'size-burger',
          name: 'Size Selection',
          isRequired: true,
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOptionEntity(
              id: 'size-regular',
              name: 'Regular',
              priceDelta: 0.00,
              isDefault: true,
            ),
            ModifierOptionEntity(
              id: 'size-large',
              name: 'Large',
              priceDelta: 5.00,
            ),
            ModifierOptionEntity(
              id: 'size-mega',
              name: 'Mega',
              priceDelta: 8.00,
            ),
          ],
        ),
        ModifierGroupEntity(
          id: 'add-ons-burger',
          name: 'Add-ons',
          minSelection: 0,
          maxSelection: 4,
          options: [
            ModifierOptionEntity(
              id: 'cheese',
              name: 'Extra Cheese',
              priceDelta: 2.00,
            ),
            ModifierOptionEntity(id: 'bacon', name: 'Bacon', priceDelta: 3.50),
            ModifierOptionEntity(
              id: 'avocado',
              name: 'Avocado',
              priceDelta: 2.50,
            ),
            ModifierOptionEntity(
              id: 'egg',
              name: 'Fried Egg',
              priceDelta: 2.00,
            ),
          ],
        ),
        ModifierGroupEntity(
          id: 'sauces-burger',
          name: 'Sauces',
          minSelection: 0,
          maxSelection: 2,
          options: [
            ModifierOptionEntity(
              id: 'ketchup',
              name: 'Ketchup',
              priceDelta: 0.00,
            ),
            ModifierOptionEntity(
              id: 'mustard',
              name: 'Mustard',
              priceDelta: 0.00,
            ),
            ModifierOptionEntity(
              id: 'bbq',
              name: 'BBQ Sauce',
              priceDelta: 1.50,
            ),
            ModifierOptionEntity(
              id: 'aioli',
              name: 'Garlic Aioli',
              priceDelta: 1.50,
            ),
          ],
        ),
      ],
      comboOptions: [
        ComboOptionEntity(
          id: 'combo-regular',
          name: 'Regular Combo',
          description: 'Fries + Regular Drink',
          priceDelta: 6.50,
        ),
        ComboOptionEntity(
          id: 'combo-large',
          name: 'Large Combo',
          description: 'Large Fries + Large Drink',
          priceDelta: 8.50,
        ),
      ],
      recommendedAddOnIds: ['item-7', 'item-8'], // Fries, Onion Rings
    ),

    // 2. MARGHERITA PIZZA
    MenuItemEntity(
      id: 'item-2',
      categoryId: 'pizza',
      name: 'Margherita Pizza',
      description: 'Fresh mozzarella, basil, and tomato sauce on crispy crust.',
      image:
          'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
      basePrice: 16.50,
      tags: ['Popular', 'Vegetarian'],
      modifierGroups: [
        ModifierGroupEntity(
          id: 'pizza-size',
          name: 'Pizza Size',
          isRequired: true,
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOptionEntity(
              id: 'small',
              name: 'Small (10")',
              priceDelta: 0.00,
            ),
            ModifierOptionEntity(
              id: 'medium',
              name: 'Medium (12")',
              priceDelta: 4.00,
              isDefault: true,
            ),
            ModifierOptionEntity(
              id: 'large',
              name: 'Large (14")',
              priceDelta: 7.00,
            ),
          ],
        ),
        ModifierGroupEntity(
          id: 'pizza-crust',
          name: 'Crust Type',
          isRequired: true,
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOptionEntity(
              id: 'thin',
              name: 'Thin Crust',
              priceDelta: 0.00,
              isDefault: true,
            ),
            ModifierOptionEntity(
              id: 'thick',
              name: 'Thick Crust',
              priceDelta: 2.00,
            ),
            ModifierOptionEntity(
              id: 'stuffed',
              name: 'Stuffed Crust',
              priceDelta: 4.00,
            ),
          ],
        ),
        ModifierGroupEntity(
          id: 'pizza-toppings',
          name: 'Extra Toppings',
          minSelection: 0,
          maxSelection: 5,
          options: [
            ModifierOptionEntity(
              id: 'mushrooms',
              name: 'Mushrooms',
              priceDelta: 2.00,
            ),
            ModifierOptionEntity(
              id: 'olives',
              name: 'Olives',
              priceDelta: 1.50,
            ),
            ModifierOptionEntity(
              id: 'peppers',
              name: 'Bell Peppers',
              priceDelta: 1.50,
            ),
            ModifierOptionEntity(
              id: 'onions',
              name: 'Onions',
              priceDelta: 1.00,
            ),
            ModifierOptionEntity(
              id: 'jalapenos',
              name: 'Jalapeños',
              priceDelta: 1.50,
            ),
          ],
        ),
      ],
      comboOptions: [
        ComboOptionEntity(
          id: 'pizza-combo',
          name: 'Pizza Combo',
          description: 'Garlic Bread + 1.25L Drink',
          priceDelta: 7.00,
        ),
      ],
    ),

    // 3. CHICKEN WINGS
    MenuItemEntity(
      id: 'item-3',
      categoryId: 'appetizers',
      name: 'Chicken Wings',
      description: 'Crispy wings with your choice of sauce.',
      image:
          'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=400',
      basePrice: 14.99,
      tags: ['Popular'],
      modifierGroups: [
        ModifierGroupEntity(
          id: 'wings-qty',
          name: 'Quantity',
          isRequired: true,
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOptionEntity(
              id: 'wings-6',
              name: '6 Wings',
              priceDelta: 0.00,
              isDefault: true,
            ),
            ModifierOptionEntity(
              id: 'wings-12',
              name: '12 Wings',
              priceDelta: 8.00,
            ),
            ModifierOptionEntity(
              id: 'wings-24',
              name: '24 Wings',
              priceDelta: 18.00,
            ),
          ],
        ),
        ModifierGroupEntity(
          id: 'wings-flavor',
          name: 'Flavor',
          isRequired: true,
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOptionEntity(
              id: 'buffalo',
              name: 'Buffalo',
              priceDelta: 0.00,
              isDefault: true,
            ),
            ModifierOptionEntity(
              id: 'bbq-wings',
              name: 'BBQ',
              priceDelta: 0.00,
            ),
            ModifierOptionEntity(
              id: 'honey-garlic',
              name: 'Honey Garlic',
              priceDelta: 1.00,
            ),
            ModifierOptionEntity(
              id: 'hot',
              name: 'Extra Hot',
              priceDelta: 1.00,
            ),
          ],
        ),
        ModifierGroupEntity(
          id: 'wings-sides',
          name: 'Add Dipping Sauce',
          minSelection: 0,
          maxSelection: 3,
          options: [
            ModifierOptionEntity(id: 'ranch', name: 'Ranch', priceDelta: 1.50),
            ModifierOptionEntity(
              id: 'blue-cheese',
              name: 'Blue Cheese',
              priceDelta: 1.50,
            ),
            ModifierOptionEntity(
              id: 'sriracha',
              name: 'Sriracha Mayo',
              priceDelta: 1.50,
            ),
          ],
        ),
      ],
    ),

    // 4. CAESAR SALAD
    MenuItemEntity(
      id: 'item-4',
      categoryId: 'salads',
      name: 'Caesar Salad',
      description:
          'Crisp romaine, parmesan, croutons, and creamy Caesar dressing.',
      image: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400',
      basePrice: 11.50,
      tags: ['Healthy'],
      modifierGroups: [
        ModifierGroupEntity(
          id: 'salad-size',
          name: 'Size',
          isRequired: true,
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOptionEntity(
              id: 'small-salad',
              name: 'Small',
              priceDelta: 0.00,
              isDefault: true,
            ),
            ModifierOptionEntity(
              id: 'large-salad',
              name: 'Large',
              priceDelta: 4.00,
            ),
          ],
        ),
        ModifierGroupEntity(
          id: 'salad-protein',
          name: 'Add Protein',
          minSelection: 0,
          maxSelection: 1,
          options: [
            ModifierOptionEntity(
              id: 'grilled-chicken',
              name: 'Grilled Chicken',
              priceDelta: 5.00,
            ),
            ModifierOptionEntity(
              id: 'grilled-shrimp',
              name: 'Grilled Shrimp',
              priceDelta: 7.00,
            ),
            ModifierOptionEntity(
              id: 'crispy-chicken',
              name: 'Crispy Chicken',
              priceDelta: 5.00,
            ),
          ],
        ),
      ],
    ),

    // 5. COFFEE (Simple, fast-add item)
    MenuItemEntity(
      id: 'item-5',
      categoryId: 'beverages',
      name: 'Coffee',
      description: 'Freshly brewed coffee.',
      image:
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',
      basePrice: 4.50,
      tags: [],
      modifierGroups: [], // No required modifiers = fast-add
    ),

    // 6. ICED LATTE
    MenuItemEntity(
      id: 'item-6',
      categoryId: 'beverages',
      name: 'Iced Latte',
      description: 'Espresso with cold milk over ice.',
      image:
          'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?w=400',
      basePrice: 6.50,
      tags: [],
      modifierGroups: [
        ModifierGroupEntity(
          id: 'coffee-size',
          name: 'Size',
          isRequired: true,
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOptionEntity(
              id: 'small-coffee',
              name: 'Small',
              priceDelta: 0.00,
              isDefault: true,
            ),
            ModifierOptionEntity(
              id: 'medium-coffee',
              name: 'Medium',
              priceDelta: 1.50,
            ),
            ModifierOptionEntity(
              id: 'large-coffee',
              name: 'Large',
              priceDelta: 2.50,
            ),
          ],
        ),
        ModifierGroupEntity(
          id: 'coffee-milk',
          name: 'Milk Type',
          minSelection: 0,
          maxSelection: 1,
          options: [
            ModifierOptionEntity(
              id: 'whole-milk',
              name: 'Whole Milk',
              priceDelta: 0.00,
              isDefault: true,
            ),
            ModifierOptionEntity(
              id: 'almond-milk',
              name: 'Almond Milk',
              priceDelta: 1.00,
            ),
            ModifierOptionEntity(
              id: 'oat-milk',
              name: 'Oat Milk',
              priceDelta: 1.00,
            ),
            ModifierOptionEntity(
              id: 'soy-milk',
              name: 'Soy Milk',
              priceDelta: 1.00,
            ),
          ],
        ),
        ModifierGroupEntity(
          id: 'coffee-extras',
          name: 'Add Extra',
          minSelection: 0,
          maxSelection: 2,
          options: [
            ModifierOptionEntity(
              id: 'extra-shot',
              name: 'Extra Shot',
              priceDelta: 1.50,
            ),
            ModifierOptionEntity(
              id: 'vanilla-syrup',
              name: 'Vanilla Syrup',
              priceDelta: 0.50,
            ),
            ModifierOptionEntity(
              id: 'caramel-syrup',
              name: 'Caramel Syrup',
              priceDelta: 0.50,
            ),
          ],
        ),
      ],
    ),

    // 7. FRIES (Simple side)
    MenuItemEntity(
      id: 'item-7',
      categoryId: 'sides',
      name: 'French Fries',
      description: 'Golden crispy fries.',
      image:
          'https://images.unsplash.com/photo-1576107232684-1279f390859f?w=400',
      basePrice: 5.50,
      tags: [],
      modifierGroups: [
        ModifierGroupEntity(
          id: 'fries-size',
          name: 'Size',
          isRequired: true,
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOptionEntity(
              id: 'small-fries',
              name: 'Small',
              priceDelta: 0.00,
              isDefault: true,
            ),
            ModifierOptionEntity(
              id: 'medium-fries',
              name: 'Medium',
              priceDelta: 2.00,
            ),
            ModifierOptionEntity(
              id: 'large-fries',
              name: 'Large',
              priceDelta: 3.50,
            ),
          ],
        ),
      ],
    ),

    // 8. ONION RINGS
    MenuItemEntity(
      id: 'item-8',
      categoryId: 'sides',
      name: 'Onion Rings',
      description: 'Crispy battered onion rings.',
      image:
          'https://images.unsplash.com/photo-1639024471283-03518883512d?w=400',
      basePrice: 6.50,
      tags: [],
      modifierGroups: [],
    ),

    // 9. CHOCOLATE CAKE
    MenuItemEntity(
      id: 'item-9',
      categoryId: 'desserts',
      name: 'Chocolate Cake',
      description: 'Rich chocolate cake with ganache.',
      image:
          'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400',
      basePrice: 8.50,
      tags: [],
      modifierGroups: [
        ModifierGroupEntity(
          id: 'cake-extras',
          name: 'Add Extra',
          minSelection: 0,
          maxSelection: 2,
          options: [
            ModifierOptionEntity(
              id: 'ice-cream',
              name: 'Vanilla Ice Cream',
              priceDelta: 3.00,
            ),
            ModifierOptionEntity(
              id: 'whipped-cream',
              name: 'Whipped Cream',
              priceDelta: 1.50,
            ),
          ],
        ),
      ],
    ),

    // 10. TACOS
    MenuItemEntity(
      id: 'item-10',
      categoryId: 'mexican',
      name: 'Beef Tacos',
      description: 'Three soft tacos with seasoned beef.',
      image:
          'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400',
      basePrice: 13.50,
      tags: ['Popular'],
      modifierGroups: [
        ModifierGroupEntity(
          id: 'taco-shell',
          name: 'Shell Type',
          isRequired: true,
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOptionEntity(
              id: 'soft-shell',
              name: 'Soft Shell',
              priceDelta: 0.00,
              isDefault: true,
            ),
            ModifierOptionEntity(
              id: 'hard-shell',
              name: 'Hard Shell',
              priceDelta: 0.00,
            ),
          ],
        ),
        ModifierGroupEntity(
          id: 'taco-toppings',
          name: 'Toppings',
          minSelection: 0,
          maxSelection: 5,
          options: [
            ModifierOptionEntity(
              id: 'sour-cream',
              name: 'Sour Cream',
              priceDelta: 1.00,
            ),
            ModifierOptionEntity(
              id: 'guacamole',
              name: 'Guacamole',
              priceDelta: 2.50,
            ),
            ModifierOptionEntity(id: 'salsa', name: 'Salsa', priceDelta: 0.00),
            ModifierOptionEntity(
              id: 'cheese-taco',
              name: 'Extra Cheese',
              priceDelta: 1.50,
            ),
            ModifierOptionEntity(
              id: 'jalapenos-taco',
              name: 'Jalapeños',
              priceDelta: 1.00,
            ),
          ],
        ),
      ],
    ),

    // 11. PASTA CARBONARA
    MenuItemEntity(
      id: 'item-11',
      categoryId: 'pasta',
      name: 'Pasta Carbonara',
      description: 'Creamy pasta with bacon and parmesan.',
      image:
          'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=400',
      basePrice: 17.50,
      tags: [],
      modifierGroups: [
        ModifierGroupEntity(
          id: 'pasta-type',
          name: 'Pasta Type',
          isRequired: true,
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOptionEntity(
              id: 'spaghetti',
              name: 'Spaghetti',
              priceDelta: 0.00,
              isDefault: true,
            ),
            ModifierOptionEntity(
              id: 'fettuccine',
              name: 'Fettuccine',
              priceDelta: 1.00,
            ),
            ModifierOptionEntity(id: 'penne', name: 'Penne', priceDelta: 0.00),
          ],
        ),
        ModifierGroupEntity(
          id: 'pasta-extras',
          name: 'Add Extra',
          minSelection: 0,
          maxSelection: 2,
          options: [
            ModifierOptionEntity(
              id: 'extra-bacon',
              name: 'Extra Bacon',
              priceDelta: 4.00,
            ),
            ModifierOptionEntity(
              id: 'garlic-bread',
              name: 'Garlic Bread',
              priceDelta: 3.50,
            ),
          ],
        ),
      ],
    ),

    // 12. SUSHI PLATTER
    MenuItemEntity(
      id: 'item-12',
      categoryId: 'japanese',
      name: 'Sushi Platter',
      description: 'Assorted nigiri and rolls.',
      image:
          'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
      basePrice: 22.00,
      tags: ['Popular'],
      modifierGroups: [
        ModifierGroupEntity(
          id: 'sushi-size',
          name: 'Platter Size',
          isRequired: true,
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOptionEntity(
              id: 'small-platter',
              name: 'Small (12 pcs)',
              priceDelta: 0.00,
              isDefault: true,
            ),
            ModifierOptionEntity(
              id: 'medium-platter',
              name: 'Medium (20 pcs)',
              priceDelta: 8.00,
            ),
            ModifierOptionEntity(
              id: 'large-platter',
              name: 'Large (32 pcs)',
              priceDelta: 18.00,
            ),
          ],
        ),
        ModifierGroupEntity(
          id: 'sushi-extras',
          name: 'Add Extra',
          minSelection: 0,
          maxSelection: 3,
          options: [
            ModifierOptionEntity(
              id: 'miso-soup',
              name: 'Miso Soup',
              priceDelta: 3.50,
            ),
            ModifierOptionEntity(
              id: 'edamame',
              name: 'Edamame',
              priceDelta: 4.00,
            ),
            ModifierOptionEntity(
              id: 'seaweed-salad',
              name: 'Seaweed Salad',
              priceDelta: 4.50,
            ),
          ],
        ),
      ],
    ),

    // 13. SMOOTHIE (fast-add)
    MenuItemEntity(
      id: 'item-13',
      categoryId: 'beverages',
      name: 'Mango Smoothie',
      description: 'Fresh mango blended with yogurt.',
      image:
          'https://images.unsplash.com/photo-1505252585461-04db1eb84625?w=400',
      basePrice: 7.50,
      tags: ['Healthy'],
      modifierGroups: [],
    ),

    // 14. FISH & CHIPS
    MenuItemEntity(
      id: 'item-14',
      categoryId: 'seafood',
      name: 'Fish & Chips',
      description: 'Beer-battered fish with crispy chips.',
      image:
          'https://images.unsplash.com/photo-1579208575657-c595a05383b7?w=400',
      basePrice: 18.50,
      tags: [],
      modifierGroups: [
        ModifierGroupEntity(
          id: 'fish-type',
          name: 'Fish Type',
          isRequired: true,
          minSelection: 1,
          maxSelection: 1,
          options: [
            ModifierOptionEntity(
              id: 'cod',
              name: 'Cod',
              priceDelta: 0.00,
              isDefault: true,
            ),
            ModifierOptionEntity(
              id: 'haddock',
              name: 'Haddock',
              priceDelta: 2.00,
            ),
            ModifierOptionEntity(
              id: 'salmon',
              name: 'Salmon',
              priceDelta: 4.00,
            ),
          ],
        ),
        ModifierGroupEntity(
          id: 'fish-sides',
          name: 'Add Side',
          minSelection: 0,
          maxSelection: 2,
          options: [
            ModifierOptionEntity(
              id: 'coleslaw',
              name: 'Coleslaw',
              priceDelta: 3.00,
            ),
            ModifierOptionEntity(
              id: 'mushy-peas',
              name: 'Mushy Peas',
              priceDelta: 2.50,
            ),
            ModifierOptionEntity(
              id: 'tartar-sauce',
              name: 'Tartar Sauce',
              priceDelta: 1.50,
            ),
          ],
        ),
      ],
    ),

    // 15. ORANGE JUICE (fast-add)
    MenuItemEntity(
      id: 'item-15',
      categoryId: 'beverages',
      name: 'Fresh Orange Juice',
      description: 'Freshly squeezed orange juice.',
      image:
          'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400',
      basePrice: 5.50,
      tags: ['Healthy'],
      modifierGroups: [],
    ),
  ];

  // ============================================================================
  // TABLES
  // ============================================================================

  static final List<TableEntity> tables = [
    // AVAILABLE TABLES
    TableEntity(
      id: 'table-1',
      number: '1',
      seats: 2,
      status: TableStatus.available,
      floorX: 1,
      floorY: 1,
    ),
    TableEntity(
      id: 'table-2',
      number: '2',
      seats: 2,
      status: TableStatus.available,
      floorX: 3,
      floorY: 1,
    ),
    TableEntity(
      id: 'table-5',
      number: '5',
      seats: 4,
      status: TableStatus.available,
      floorX: 1,
      floorY: 3,
    ),
    TableEntity(
      id: 'table-9',
      number: '9',
      seats: 6,
      status: TableStatus.available,
      floorX: 5,
      floorY: 3,
    ),
    TableEntity(
      id: 'table-13',
      number: '13',
      seats: 2,
      status: TableStatus.available,
      floorX: 1,
      floorY: 5,
    ),

    // OCCUPIED TABLES
    TableEntity(
      id: 'table-3',
      number: '3',
      seats: 4,
      status: TableStatus.occupied,
      serverName: 'Sarah K.',
      floorX: 5,
      floorY: 1,
    ),
    TableEntity(
      id: 'table-4',
      number: '4',
      seats: 4,
      status: TableStatus.occupied,
      serverName: 'Mike T.',
      floorX: 7,
      floorY: 1,
    ),
    TableEntity(
      id: 'table-6',
      number: '6',
      seats: 4,
      status: TableStatus.occupied,
      serverName: 'Sarah K.',
      floorX: 3,
      floorY: 3,
    ),
    TableEntity(
      id: 'table-10',
      number: '10',
      seats: 6,
      status: TableStatus.occupied,
      serverName: 'James P.',
      floorX: 7,
      floorY: 3,
    ),
    TableEntity(
      id: 'table-14',
      number: '14',
      seats: 4,
      status: TableStatus.occupied,
      serverName: 'Emma L.',
      floorX: 3,
      floorY: 5,
    ),

    // RESERVED TABLES
    TableEntity(
      id: 'table-7',
      number: '7',
      seats: 6,
      status: TableStatus.reserved,
      floorX: 1,
      floorY: 7,
    ),
    TableEntity(
      id: 'table-11',
      number: '11',
      seats: 8,
      status: TableStatus.reserved,
      floorX: 5,
      floorY: 5,
    ),

    // CLEANING TABLES
    TableEntity(
      id: 'table-8',
      number: '8',
      seats: 4,
      status: TableStatus.cleaning,
      floorX: 3,
      floorY: 7,
    ),
    TableEntity(
      id: 'table-12',
      number: '12',
      seats: 2,
      status: TableStatus.cleaning,
      floorX: 7,
      floorY: 5,
    ),

    // MORE AVAILABLE TABLES
    TableEntity(
      id: 'table-15',
      number: '15',
      seats: 4,
      status: TableStatus.available,
      floorX: 5,
      floorY: 7,
    ),
    TableEntity(
      id: 'table-16',
      number: '16',
      seats: 2,
      status: TableStatus.available,
      floorX: 7,
      floorY: 7,
    ),
    TableEntity(
      id: 'table-17',
      number: '17',
      seats: 6,
      status: TableStatus.available,
      floorX: 1,
      floorY: 9,
    ),
    TableEntity(
      id: 'table-18',
      number: '18',
      seats: 4,
      status: TableStatus.available,
      floorX: 3,
      floorY: 9,
    ),
    TableEntity(
      id: 'table-19',
      number: '19',
      seats: 4,
      status: TableStatus.available,
      floorX: 5,
      floorY: 9,
    ),
    TableEntity(
      id: 'table-20',
      number: '20',
      seats: 8,
      status: TableStatus.available,
      floorX: 7,
      floorY: 9,
    ),
  ];
}
