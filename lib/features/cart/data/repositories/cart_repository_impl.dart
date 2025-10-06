import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';
import '../models/cart_item_model.dart';

/// Cart repository implementation
class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCartItems() async {
    try {
      final items = await localDataSource.getCartItems();
      return Right(items.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(CartItemEntity item) async {
    try {
      final model = CartItemModel.fromEntity(item);
      await localDataSource.addToCart(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateCartItem(String lineItemId, int quantity) async {
    try {
      await localDataSource.updateCartItem(lineItemId, quantity);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String lineItemId) async {
    try {
      await localDataSource.removeFromCart(lineItemId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await localDataSource.clearCart();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, double>> getCartTotal() async {
    try {
      final total = await localDataSource.getCartTotal();
      return Right(total);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, int>> getCartItemCount() async {
    try {
      final count = await localDataSource.getCartItemCount();
      return Right(count);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
