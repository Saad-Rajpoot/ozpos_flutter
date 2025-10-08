import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/addon_management_entities.dart';

/// Addon repository interface
abstract class AddonRepository {
  /// Get all addon categories
  Future<Either<Failure, List<AddonCategory>>> getAddonCategories();
}
