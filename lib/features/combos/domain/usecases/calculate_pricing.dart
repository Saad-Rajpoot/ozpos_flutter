import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/combo_entity.dart';
import '../entities/combo_pricing_entity.dart';
import '../repositories/combo_repository.dart';

/// Calculate pricing use case
class CalculatePricing
    implements UseCase<ComboPricingEntity, CalculatePricingParams> {
  final ComboRepository repository;

  CalculatePricing({required this.repository});

  @override
  Future<Either<Failure, ComboPricingEntity>> call(
      CalculatePricingParams params) async {
    return repository.calculatePricing(params.combo);
  }
}

class CalculatePricingParams {
  final ComboEntity combo;

  const CalculatePricingParams({required this.combo});
}
