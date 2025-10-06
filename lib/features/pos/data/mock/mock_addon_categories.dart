import '../../domain/entities/menu_item_edit_entity.dart';

/// Mock add-on categories for testing menu editor
/// Matches the React prototype data structure
const List<AddOnCategoryEntity> mockAddOnCategories = [
  AddOnCategoryEntity(
    id: 'cheese-options',
    name: 'Cheese Options',
    description: 'Choose your cheese',
    items: [
      AddOnOptionEntity(
        id: 'cheese-cheddar',
        name: 'Cheddar Cheese',
        basePrice: 1.50,
      ),
      AddOnOptionEntity(
        id: 'cheese-mozzarella',
        name: 'Mozzarella',
        basePrice: 1.50,
      ),
      AddOnOptionEntity(
        id: 'cheese-parmesan',
        name: 'Parmesan',
        basePrice: 1.75,
      ),
      AddOnOptionEntity(
        id: 'cheese-swiss',
        name: 'Swiss Cheese',
        basePrice: 1.75,
      ),
      AddOnOptionEntity(
        id: 'cheese-blue',
        name: 'Blue Cheese',
        basePrice: 2.00,
      ),
    ],
  ),
  AddOnCategoryEntity(
    id: 'sauces',
    name: 'Sauces',
    description: 'Choose your sauces',
    items: [
      AddOnOptionEntity(
        id: 'sauce-ketchup',
        name: 'Ketchup',
        basePrice: 0.50,
      ),
      AddOnOptionEntity(
        id: 'sauce-mustard',
        name: 'Mustard',
        basePrice: 0.50,
      ),
      AddOnOptionEntity(
        id: 'sauce-mayo',
        name: 'Mayonnaise',
        basePrice: 0.50,
      ),
      AddOnOptionEntity(
        id: 'sauce-bbq',
        name: 'BBQ Sauce',
        basePrice: 0.75,
      ),
      AddOnOptionEntity(
        id: 'sauce-ranch',
        name: 'Ranch',
        basePrice: 0.75,
      ),
      AddOnOptionEntity(
        id: 'sauce-sriracha',
        name: 'Sriracha',
        basePrice: 0.75,
      ),
      AddOnOptionEntity(
        id: 'sauce-aioli',
        name: 'Aioli',
        basePrice: 0.85,
      ),
    ],
  ),
  AddOnCategoryEntity(
    id: 'extra-toppings',
    name: 'Extra Toppings',
    description: 'Add extra toppings',
    items: [
      AddOnOptionEntity(
        id: 'topping-bacon',
        name: 'Bacon',
        basePrice: 2.50,
      ),
      AddOnOptionEntity(
        id: 'topping-egg',
        name: 'Fried Egg',
        basePrice: 1.50,
      ),
      AddOnOptionEntity(
        id: 'topping-avocado',
        name: 'Avocado',
        basePrice: 2.00,
      ),
      AddOnOptionEntity(
        id: 'topping-mushrooms',
        name: 'Mushrooms',
        basePrice: 1.50,
      ),
      AddOnOptionEntity(
        id: 'topping-onions',
        name: 'Grilled Onions',
        basePrice: 1.00,
      ),
      AddOnOptionEntity(
        id: 'topping-jalapenos',
        name: 'Jalapeños',
        basePrice: 0.75,
      ),
      AddOnOptionEntity(
        id: 'topping-pickles',
        name: 'Pickles',
        basePrice: 0.50,
      ),
    ],
  ),
  AddOnCategoryEntity(
    id: 'spices',
    name: 'Spices & Seasonings',
    description: 'Add spices',
    items: [
      AddOnOptionEntity(
        id: 'spice-salt',
        name: 'Extra Salt',
        basePrice: 0.00,
      ),
      AddOnOptionEntity(
        id: 'spice-pepper',
        name: 'Black Pepper',
        basePrice: 0.00,
      ),
      AddOnOptionEntity(
        id: 'spice-paprika',
        name: 'Paprika',
        basePrice: 0.25,
      ),
      AddOnOptionEntity(
        id: 'spice-chili',
        name: 'Chili Flakes',
        basePrice: 0.25,
      ),
      AddOnOptionEntity(
        id: 'spice-garlic',
        name: 'Garlic Powder',
        basePrice: 0.25,
      ),
    ],
  ),
];
