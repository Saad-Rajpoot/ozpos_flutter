import '../../../../core/errors/exceptions.dart';
import '../models/cart_item_model.dart';
import 'cart_local_datasource.dart';

/// Mock cart local data source for web platform
class MockCartLocalDataSource implements CartLocalDataSource {
  @override
  Future<List<CartItemModel>> getCartItems() async {
    // Return empty list for web
    return [];
  }

  @override
  Future<void> addToCart(CartItemModel item) async {
    // No-op for web
  }

  @override
  Future<void> updateCartItem(String lineItemId, int quantity) async {
    // No-op for web
  }

  @override
  Future<void> removeFromCart(String lineItemId) async {
    // No-op for web
  }

  @override
  Future<void> clearCart() async {
    // No-op for web
  }

  @override
  Future<double> getCartTotal() async {
    return 0.0;
  }

  @override
  Future<int> getCartItemCount() async {
    return 0;
  }
}
