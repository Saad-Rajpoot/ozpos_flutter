import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/cart_repository.dart';

/// Clear cart use case
class ClearCart implements UseCase<void, NoParams> {
  final CartRepository repository;

  ClearCart({required this.repository});

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearCart();
  }
}
