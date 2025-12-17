import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/combo_pricing_entity.dart';
import '../repositories/combo_repository.dart';

/// Use case to get combo pricing from repository
class GetComboPricing implements UseCase<List<ComboPricingEntity>, NoParams> {
  final ComboRepository repository;

  GetComboPricing(this.repository);

  @override
  Future<Either<Failure, List<ComboPricingEntity>>> call(
    NoParams params,
  ) async {
    return repository.getComboPricing();
  }
}
