import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/repository_error_handler.dart';
import '../../domain/entities/combo_entity.dart';
import '../../domain/entities/combo_slot_entity.dart';
import '../../domain/entities/combo_availability_entity.dart';
import '../../domain/entities/combo_limits_entity.dart';
import '../../domain/entities/combo_option_entity.dart';
import '../../domain/entities/combo_pricing_entity.dart';
import '../../domain/repositories/combo_repository.dart';
import '../datasources/combo_data_source.dart';

/// Combo repository implementation
class ComboRepositoryImpl implements ComboRepository {
  final ComboDataSource comboDataSource;
  final NetworkInfo networkInfo;

  ComboRepositoryImpl({
    required this.comboDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ComboEntity>>> getCombos() async {
    return RepositoryErrorHandler.handleOperation<List<ComboEntity>>(
      operation: () async => await comboDataSource.getCombos(),
      networkInfo: networkInfo,
      operationName: 'loading combos',
    );
  }

  @override
  Future<Either<Failure, List<ComboSlotEntity>>> getComboSlots() async {
    return RepositoryErrorHandler.handleOperation<List<ComboSlotEntity>>(
      operation: () async => await comboDataSource.getComboSlots(),
      networkInfo: networkInfo,
      operationName: 'loading combo slots',
    );
  }

  @override
  Future<Either<Failure, List<ComboAvailabilityEntity>>>
      getComboAvailability() async {
    return RepositoryErrorHandler.handleOperation<
        List<ComboAvailabilityEntity>>(
      operation: () async => await comboDataSource.getComboAvailability(),
      networkInfo: networkInfo,
      operationName: 'loading combo availability',
    );
  }

  @override
  Future<Either<Failure, List<ComboLimitsEntity>>> getComboLimits() async {
    return RepositoryErrorHandler.handleOperation<List<ComboLimitsEntity>>(
      operation: () async => await comboDataSource.getComboLimits(),
      networkInfo: networkInfo,
      operationName: 'loading combo limits',
    );
  }

  @override
  Future<Either<Failure, List<ComboOptionEntity>>> getComboOptions() async {
    return RepositoryErrorHandler.handleOperation<List<ComboOptionEntity>>(
      operation: () async => await comboDataSource.getComboOptions(),
      networkInfo: networkInfo,
      operationName: 'loading combo options',
    );
  }

  @override
  Future<Either<Failure, List<ComboPricingEntity>>> getComboPricing() async {
    return RepositoryErrorHandler.handleOperation<List<ComboPricingEntity>>(
      operation: () async => await comboDataSource.getComboPricing(),
      networkInfo: networkInfo,
      operationName: 'loading combo pricing',
    );
  }

  @override
  Future<Either<Failure, ComboEntity>> createCombo(ComboEntity combo) async {
    return RepositoryErrorHandler.handleOperation<ComboEntity>(
      operation: () async => await comboDataSource.createCombo(combo),
      networkInfo: networkInfo,
      operationName: 'creating combo',
    );
  }

  @override
  Future<Either<Failure, ComboEntity>> updateCombo(ComboEntity combo) async {
    return RepositoryErrorHandler.handleOperation<ComboEntity>(
      operation: () async => await comboDataSource.updateCombo(combo),
      networkInfo: networkInfo,
      operationName: 'updating combo',
    );
  }

  @override
  Future<Either<Failure, void>> deleteCombo(String comboId) async {
    return RepositoryErrorHandler.handleOperation<void>(
      operation: () async => await comboDataSource.deleteCombo(comboId),
      networkInfo: networkInfo,
      operationName: 'deleting combo',
    );
  }

  @override
  Future<Either<Failure, ComboEntity>> duplicateCombo(String comboId,
      {String? newName}) async {
    return RepositoryErrorHandler.handleOperation<ComboEntity>(
      operation: () async =>
          await comboDataSource.duplicateCombo(comboId, newName: newName),
      networkInfo: networkInfo,
      operationName: 'duplicating combo',
    );
  }

  @override
  Future<Either<Failure, ComboPricingEntity>> calculatePricing(
      ComboEntity combo) async {
    // Business logic for pricing calculation
    double basePrice = combo.pricing.totalIfSeparate;

    // For now, return the existing pricing as-is since the pricing logic
    // should be handled by the ComboPricingEntity factory methods
    // This method would typically recalculate based on current slot configuration

    final calculatedPricing = combo.pricing.copyWith(
      totalIfSeparate: basePrice,
      calculatedAt: DateTime.now(),
    );

    return Right(calculatedPricing);
  }
}
