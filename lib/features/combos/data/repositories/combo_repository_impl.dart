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
}
