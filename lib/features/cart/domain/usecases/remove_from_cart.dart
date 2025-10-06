import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/cart_repository.dart';

/// Remove from cart use case
class RemoveFromCart implements UseCase<void, String> {
  final CartRepository repository;

  RemoveFromCart({required this.repository});

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.removeFromCart(params);
  }
}
