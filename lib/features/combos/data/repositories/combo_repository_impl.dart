import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
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
    if (await networkInfo.isConnected) {
      try {
        final combos = await comboDataSource.getCombos();
        return Right(combos);
      } on ServerException {
        return Left(ServerFailure(message: 'Server error'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }

  @override
  Future<Either<Failure, List<ComboSlotEntity>>> getComboSlots() async {
    if (await networkInfo.isConnected) {
      try {
        final comboSlots = await comboDataSource.getComboSlots();
        return Right(comboSlots);
      } on ServerException {
        return Left(ServerFailure(message: 'Server error'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }

  @override
  Future<Either<Failure, List<ComboAvailabilityEntity>>>
      getComboAvailability() async {
    if (await networkInfo.isConnected) {
      try {
        final comboAvailability = await comboDataSource.getComboAvailability();
        return Right(comboAvailability);
      } on ServerException {
        return Left(ServerFailure(message: 'Server error'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }

  @override
  Future<Either<Failure, List<ComboLimitsEntity>>> getComboLimits() async {
    if (await networkInfo.isConnected) {
      try {
        final comboLimits = await comboDataSource.getComboLimits();
        return Right(comboLimits);
      } on ServerException {
        return Left(ServerFailure(message: 'Server error'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }

  @override
  Future<Either<Failure, List<ComboOptionEntity>>> getComboOptions() async {
    if (await networkInfo.isConnected) {
      try {
        final comboOptions = await comboDataSource.getComboOptions();
        return Right(comboOptions);
      } on ServerException {
        return Left(ServerFailure(message: 'Server error'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }

  @override
  Future<Either<Failure, List<ComboPricingEntity>>> getComboPricing() async {
    if (await networkInfo.isConnected) {
      try {
        final comboPricing = await comboDataSource.getComboPricing();
        return Right(comboPricing);
      } on ServerException {
        return Left(ServerFailure(message: 'Server error'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }

  @override
  Future<Either<Failure, ComboEntity>> createCombo(ComboEntity combo) async {
    if (await networkInfo.isConnected) {
      try {
        final createdCombo = await comboDataSource.createCombo(combo);
        return Right(createdCombo);
      } on ServerException {
        return Left(ServerFailure(message: 'Failed to create combo'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }

  @override
  Future<Either<Failure, ComboEntity>> updateCombo(ComboEntity combo) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedCombo = await comboDataSource.updateCombo(combo);
        return Right(updatedCombo);
      } on ServerException {
        return Left(ServerFailure(message: 'Failed to update combo'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCombo(String comboId) async {
    if (await networkInfo.isConnected) {
      try {
        await comboDataSource.deleteCombo(comboId);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure(message: 'Failed to delete combo'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }

  @override
  Future<Either<Failure, ComboEntity>> duplicateCombo(String comboId,
      {String? newName}) async {
    if (await networkInfo.isConnected) {
      try {
        final duplicatedCombo =
            await comboDataSource.duplicateCombo(comboId, newName: newName);
        return Right(duplicatedCombo);
      } on ServerException {
        return Left(ServerFailure(message: 'Failed to duplicate combo'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> validateCombo(ComboEntity combo) async {
    // Business logic validation
    final errors = <String>[];

    if (combo.name.isEmpty) {
      errors.add('Combo name is required');
    }

    if (combo.description.isEmpty) {
      errors.add('Combo description is required');
    }

    if (combo.slots.isEmpty) {
      errors.add('Combo must have at least one slot');
    }

    for (final slot in combo.slots) {
      if (slot.specificItemIds.isEmpty && slot.categoryId == null) {
        errors.add('All slots must contain at least one item or category');
        break;
      }
    }

    if (combo.pricing.totalIfSeparate <= 0) {
      errors.add('Combo must have a valid base price');
    }

    return Right(errors);
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
