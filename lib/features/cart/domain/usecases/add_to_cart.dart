import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

/// Add to cart use case
class AddToCart implements UseCase<void, CartItemEntity> {
  final CartRepository repository;

  AddToCart({required this.repository});

  @override
  Future<Either<Failure, void>> call(CartItemEntity params) async {
    return await repository.addToCart(params);
  }
}
