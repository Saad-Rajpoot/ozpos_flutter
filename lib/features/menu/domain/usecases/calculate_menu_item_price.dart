import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/menu_item_entity.dart';
import '../services/menu_item_price_calculator.dart';

/// Use case for calculating menu item price
/// Encapsulates the business logic for calculating prices with modifiers and combos
class CalculateMenuItemPriceUseCase
    implements UseCase<double, CalculateMenuItemPriceParams> {
  const CalculateMenuItemPriceUseCase();

  @override
  Future<Either<Failure, double>> call(
    CalculateMenuItemPriceParams params,
  ) async {
    try {
      final price = MenuItemPriceCalculator.calculatePrice(
        item: params.item,
        selectedModifiers: params.selectedModifiers,
        selectedComboId: params.selectedComboId,
        quantity: params.quantity,
      );

      return Right(price);
    } catch (e) {
      return Left(ValidationFailure(
        message: 'Price calculation failed: ${e.toString()}',
      ));
    }
  }
}

/// Parameters for calculating menu item price
class CalculateMenuItemPriceParams {
  final MenuItemEntity item;
  final Map<String, List<String>> selectedModifiers;
  final String? selectedComboId;
  final int quantity;

  const CalculateMenuItemPriceParams({
    required this.item,
    required this.selectedModifiers,
    this.selectedComboId,
    required this.quantity,
  });
}
