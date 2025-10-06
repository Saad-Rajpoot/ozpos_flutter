import '../models/menu_item_model.dart';
import '../models/menu_category_model.dart';

/// Mock menu data source for testing without backend
class MenuMockDataSource {
  static List<MenuCategoryModel> getMockCategories() {
    final now = DateTime.now();
    return [
      MenuCategoryModel(
        id: 'cat-1',
        name: 'Pizza',
        description: 'Delicious wood-fired pizzas',
        image: 'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Pizza',
        isActive: true,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      ),
      MenuCategoryModel(
        id: 'cat-2',
        name: 'Burgers',
        description: 'Juicy gourmet burgers',
        image: 'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Burgers',
        isActive: true,
        sortOrder: 2,
        createdAt: now,
        updatedAt: now,
      ),
      MenuCategoryModel(
        id: 'cat-3',
        name: 'Pasta',
        description: 'Fresh homemade pasta',
        image: 'https://via.placeholder.com/300x200/FFE66D/FFFFFF?text=Pasta',
        isActive: true,
        sortOrder: 3,
        createdAt: now,
        updatedAt: now,
      ),
      MenuCategoryModel(
        id: 'cat-4',
        name: 'Salads',
        description: 'Fresh and healthy salads',
        image: 'https://via.placeholder.com/300x200/95E1D3/FFFFFF?text=Salads',
        isActive: true,
        sortOrder: 4,
        createdAt: now,
        updatedAt: now,
      ),
      MenuCategoryModel(
        id: 'cat-5',
        name: 'Desserts',
        description: 'Sweet treats',
        image: 'https://via.placeholder.com/300x200/F38181/FFFFFF?text=Desserts',
        isActive: true,
        sortOrder: 5,
        createdAt: now,
        updatedAt: now,
      ),
      MenuCategoryModel(
        id: 'cat-6',
        name: 'Beverages',
        description: 'Hot and cold drinks',
        image: 'https://via.placeholder.com/300x200/AA96DA/FFFFFF?text=Beverages',
        isActive: true,
        sortOrder: 6,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  static List<MenuItemModel> getMockMenuItems() {
    return [
      // Pizza
      MenuItemModel(
        id: 'item-1',
        name: 'Margherita Pizza',
        description: 'Classic tomato sauce, mozzarella, and fresh basil',
        categoryId: 'cat-1',
        basePrice: 18.99,
        image: 'https://via.placeholder.com/400x300/FF6B6B/FFFFFF?text=Margherita',
        tags: ['Popular', 'Vegetarian'],
      ),
      MenuItemModel(
        id: 'item-2',
        name: 'Pepperoni Pizza',
        description: 'Loaded with pepperoni and mozzarella cheese',
        categoryId: 'cat-1',
        basePrice: 21.99,
        image: 'https://via.placeholder.com/400x300/FF6B6B/FFFFFF?text=Pepperoni',
        tags: ['Popular', 'Best Seller'],
      ),
      MenuItemModel(
        id: 'item-3',
        name: 'Hawaiian Pizza',
        description: 'Ham, pineapple, and mozzarella',
        categoryId: 'cat-1',
        basePrice: 20.99,
        image: 'https://via.placeholder.com/400x300/FF6B6B/FFFFFF?text=Hawaiian',
        tags: [],
      ),
      
      // Burgers
      MenuItemModel(
        id: 'item-4',
        name: 'Classic Beef Burger',
        description: 'Juicy beef patty with lettuce, tomato, and special sauce',
        categoryId: 'cat-2',
        basePrice: 15.99,
        image: 'https://via.placeholder.com/400x300/4ECDC4/FFFFFF?text=Beef+Burger',
        tags: ['Popular'],
      ),
      MenuItemModel(
        id: 'item-5',
        name: 'Chicken Burger',
        description: 'Grilled chicken breast with mayo and pickles',
        categoryId: 'cat-2',
        basePrice: 14.99,
        image: 'https://via.placeholder.com/400x300/4ECDC4/FFFFFF?text=Chicken+Burger',
        tags: [],
      ),
      MenuItemModel(
        id: 'item-6',
        name: 'Veggie Burger',
        description: 'Plant-based patty with fresh vegetables',
        categoryId: 'cat-2',
        basePrice: 13.99,
        image: 'https://via.placeholder.com/400x300/4ECDC4/FFFFFF?text=Veggie+Burger',
        tags: ['Vegetarian', 'Vegan'],
      ),
      
      // Pasta
      MenuItemModel(
        id: 'item-7',
        name: 'Spaghetti Carbonara',
        description: 'Creamy pasta with bacon and parmesan',
        categoryId: 'cat-3',
        basePrice: 16.99,
        image: 'https://via.placeholder.com/400x300/FFE66D/FFFFFF?text=Carbonara',
        tags: ['Popular'],
      ),
      MenuItemModel(
        id: 'item-8',
        name: 'Penne Arrabbiata',
        description: 'Spicy tomato sauce with garlic and chili',
        categoryId: 'cat-3',
        basePrice: 14.99,
        image: 'https://via.placeholder.com/400x300/FFE66D/FFFFFF?text=Arrabbiata',
        tags: ['Spicy', 'Vegetarian'],
      ),
      
      // Salads
      MenuItemModel(
        id: 'item-9',
        name: 'Caesar Salad',
        description: 'Romaine lettuce, croutons, parmesan, Caesar dressing',
        categoryId: 'cat-4',
        basePrice: 11.99,
        image: 'https://via.placeholder.com/400x300/95E1D3/FFFFFF?text=Caesar+Salad',
        tags: ['Healthy', 'Popular'],
      ),
      MenuItemModel(
        id: 'item-10',
        name: 'Greek Salad',
        description: 'Feta cheese, olives, cucumber, tomatoes',
        categoryId: 'cat-4',
        basePrice: 10.99,
        image: 'https://via.placeholder.com/400x300/95E1D3/FFFFFF?text=Greek+Salad',
        tags: ['Healthy', 'Vegetarian'],
      ),
      
      // Desserts
      MenuItemModel(
        id: 'item-11',
        name: 'Chocolate Cake',
        description: 'Rich chocolate cake with chocolate frosting',
        categoryId: 'cat-5',
        basePrice: 7.99,
        image: 'https://via.placeholder.com/400x300/F38181/FFFFFF?text=Chocolate+Cake',
        tags: ['Popular', 'Sweet'],
      ),
      MenuItemModel(
        id: 'item-12',
        name: 'Tiramisu',
        description: 'Classic Italian coffee-flavored dessert',
        categoryId: 'cat-5',
        basePrice: 8.99,
        image: 'https://via.placeholder.com/400x300/F38181/FFFFFF?text=Tiramisu',
        tags: ['Popular'],
      ),
      
      // Beverages
      MenuItemModel(
        id: 'item-13',
        name: 'Coca Cola',
        description: 'Chilled soft drink',
        categoryId: 'cat-6',
        basePrice: 3.50,
        image: 'https://via.placeholder.com/400x300/AA96DA/FFFFFF?text=Coca+Cola',
        tags: [],
      ),
      MenuItemModel(
        id: 'item-14',
        name: 'Fresh Orange Juice',
        description: 'Freshly squeezed orange juice',
        categoryId: 'cat-6',
        basePrice: 5.50,
        image: 'https://via.placeholder.com/400x300/AA96DA/FFFFFF?text=Orange+Juice',
        tags: ['Fresh', 'Healthy'],
      ),
      MenuItemModel(
        id: 'item-15',
        name: 'Cappuccino',
        description: 'Espresso with steamed milk and foam',
        categoryId: 'cat-6',
        basePrice: 4.50,
        image: 'https://via.placeholder.com/400x300/AA96DA/FFFFFF?text=Cappuccino',
        tags: ['Hot', 'Coffee'],
      ),
    ];
  }
}
