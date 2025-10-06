import 'package:sqflite/sqflite.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/cart_item_model.dart';

/// Cart local data source interface
abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> addToCart(CartItemModel item);
  Future<void> updateCartItem(String lineItemId, int quantity);
  Future<void> removeFromCart(String lineItemId);
  Future<void> clearCart();
  Future<double> getCartTotal();
  Future<int> getCartItemCount();
}

/// Cart local data source implementation
class CartLocalDataSourceImpl implements CartLocalDataSource {
  final Database database;

  CartLocalDataSourceImpl({required this.database});

  @override
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query(
        'cart_items',
        orderBy: 'added_at ASC',
      );
      return maps.map((map) => CartItemModel.fromJson(map)).toList();
    } catch (e) {
      // For web, return empty list if database is not available
      if (e.toString().contains('Database operations not supported on web')) {
        return [];
      }
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> addToCart(CartItemModel item) async {
    try {
      await database.insert(
        'cart_items',
        item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> updateCartItem(String lineItemId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(lineItemId);
        return;
      }

      await database.update(
        'cart_items',
        {'quantity': quantity, 'total_price': 0}, // Will be calculated
        where: 'line_item_id = ?',
        whereArgs: [lineItemId],
      );
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> removeFromCart(String lineItemId) async {
    try {
      await database.delete(
        'cart_items',
        where: 'line_item_id = ?',
        whereArgs: [lineItemId],
      );
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await database.delete('cart_items');
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<double> getCartTotal() async {
    try {
      final result = await database.rawQuery(
        'SELECT SUM(total_price) as total FROM cart_items',
      );
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<int> getCartItemCount() async {
    try {
      final result = await database.rawQuery(
        'SELECT SUM(quantity) as count FROM cart_items',
      );
      return (result.first['count'] as num?)?.toInt() ?? 0;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
