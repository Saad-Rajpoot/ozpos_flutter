import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/cart_repository.dart';

/// Update cart item use case parameters
class UpdateCartItemParams {
  final String lineItemId;
  final int quantity;

  const UpdateCartItemParams({
    required this.lineItemId,
    required this.quantity,
  });
}

/// Update cart item use case
class UpdateCartItem implements UseCase<void, UpdateCartItemParams> {
  final CartRepository repository;

  UpdateCartItem({required this.repository});

  @override
  Future<Either<Failure, void>> call(UpdateCartItemParams params) async {
    return await repository.updateCartItem(params.lineItemId, params.quantity);
  }
}
