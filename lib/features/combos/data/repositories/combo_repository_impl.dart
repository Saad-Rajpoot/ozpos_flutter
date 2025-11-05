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
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection available'),
      );
    }

    try {
      final combos = await comboDataSource.getCombos();
      return Right(combos);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Unexpected error loading combos: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ComboSlotEntity>>> getComboSlots() async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection available'),
      );
    }

    try {
      final comboSlots = await comboDataSource.getComboSlots();
      return Right(comboSlots);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Unexpected error loading combo slots: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ComboAvailabilityEntity>>>
      getComboAvailability() async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection available'),
      );
    }

    try {
      final comboAvailability = await comboDataSource.getComboAvailability();
      return Right(comboAvailability);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Unexpected error loading combo availability: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ComboLimitsEntity>>> getComboLimits() async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection available'),
      );
    }

    try {
      final comboLimits = await comboDataSource.getComboLimits();
      return Right(comboLimits);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Unexpected error loading combo limits: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ComboOptionEntity>>> getComboOptions() async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection available'),
      );
    }

    try {
      final comboOptions = await comboDataSource.getComboOptions();
      return Right(comboOptions);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Unexpected error loading combo options: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ComboPricingEntity>>> getComboPricing() async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection available'),
      );
    }

    try {
      final comboPricing = await comboDataSource.getComboPricing();
      return Right(comboPricing);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Unexpected error loading combo pricing: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, ComboEntity>> createCombo(ComboEntity combo) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection available'),
      );
    }

    try {
      final createdCombo = await comboDataSource.createCombo(combo);
      return Right(createdCombo);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Unexpected error creating combo: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, ComboEntity>> updateCombo(ComboEntity combo) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection available'),
      );
    }

    try {
      final updatedCombo = await comboDataSource.updateCombo(combo);
      return Right(updatedCombo);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Unexpected error updating combo: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteCombo(String comboId) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection available'),
      );
    }

    try {
      await comboDataSource.deleteCombo(comboId);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Unexpected error deleting combo: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, ComboEntity>> duplicateCombo(String comboId,
      {String? newName}) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection available'),
      );
    }

    try {
      final duplicatedCombo =
          await comboDataSource.duplicateCombo(comboId, newName: newName);
      return Right(duplicatedCombo);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Unexpected error duplicating combo: $e'),
      );
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
