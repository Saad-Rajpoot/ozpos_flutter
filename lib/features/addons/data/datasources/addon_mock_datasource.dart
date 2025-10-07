import "../../domain/entities/addon_management_entities.dart";

/// Mock add-on categories for testing menu editor
/// Matches the React prototype data structure
final List<AddonCategory> mockAddOnCategories = [
  AddonCategory(
    id: 'cheese-options',
    name: 'Cheese Options',
    description: 'Choose your cheese',
    items: [
      AddonItem(
        id: 'cheese-cheddar',
        name: 'Cheddar Cheese',
        basePriceDelta: 1.50,
      ),
      AddonItem(
        id: 'cheese-mozzarella',
        name: 'Mozzarella',
        basePriceDelta: 1.50,
      ),
      AddonItem(id: 'cheese-parmesan', name: 'Parmesan', basePriceDelta: 1.75),
      AddonItem(id: 'cheese-swiss', name: 'Swiss Cheese', basePriceDelta: 1.75),
      AddonItem(id: 'cheese-blue', name: 'Blue Cheese', basePriceDelta: 2.00),
    ],
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),

  AddonCategory(
    id: 'sauces',
    name: 'Sauces',
    description: 'Choose your sauces',
    items: [
      AddonItem(id: 'sauce-ketchup', name: 'Ketchup', basePriceDelta: 0.50),
      AddonItem(id: 'sauce-mustard', name: 'Mustard', basePriceDelta: 0.50),
      AddonItem(id: 'sauce-mayo', name: 'Mayonnaise', basePriceDelta: 0.50),
      AddonItem(id: 'sauce-bbq', name: 'BBQ Sauce', basePriceDelta: 0.75),
      AddonItem(id: 'sauce-ranch', name: 'Ranch', basePriceDelta: 0.75),
      AddonItem(id: 'sauce-sriracha', name: 'Sriracha', basePriceDelta: 0.75),
      AddonItem(id: 'sauce-aioli', name: 'Aioli', basePriceDelta: 0.85),
    ],
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
  AddonCategory(
    id: 'extra-toppings',
    name: 'Extra Toppings',
    description: 'Add extra toppings',
    items: [
      AddonItem(id: 'topping-bacon', name: 'Bacon', basePriceDelta: 2.50),
      AddonItem(id: 'topping-egg', name: 'Fried Egg', basePriceDelta: 1.50),
      AddonItem(id: 'topping-avocado', name: 'Avocado', basePriceDelta: 2.00),
      AddonItem(
        id: 'topping-mushrooms',
        name: 'Mushrooms',
        basePriceDelta: 1.50,
      ),
      AddonItem(
        id: 'topping-onions',
        name: 'Grilled Onions',
        basePriceDelta: 1.00,
      ),
      AddonItem(
        id: 'topping-jalapenos',
        name: 'Jalapeños',
        basePriceDelta: 0.75,
      ),
      AddonItem(id: 'topping-pickles', name: 'Pickles', basePriceDelta: 0.50),
    ],
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
  AddonCategory(
    id: 'spices',
    name: 'Spices & Seasonings',
    description: 'Add spices',
    items: [
      AddonItem(id: 'spice-salt', name: 'Extra Salt', basePriceDelta: 0.00),
      AddonItem(id: 'spice-pepper', name: 'Black Pepper', basePriceDelta: 0.00),
      AddonItem(id: 'spice-paprika', name: 'Paprika', basePriceDelta: 0.25),
      AddonItem(id: 'spice-chili', name: 'Chili Flakes', basePriceDelta: 0.25),
      AddonItem(
        id: 'spice-garlic',
        name: 'Garlic Powder',
        basePriceDelta: 0.25,
      ),
    ],
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
];
