import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/settings_entities.dart';

abstract class SettingsRepository {
  Future<Either<Failure, List<SettingsCategoryEntity>>> getCategories();
}
