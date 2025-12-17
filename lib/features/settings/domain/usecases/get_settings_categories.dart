import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/settings_entities.dart';
import '../repositories/settings_repository.dart';

class GetSettingsCategories
    implements UseCase<List<SettingsCategoryEntity>, NoParams> {
  final SettingsRepository repository;

  GetSettingsCategories({required this.repository});

  @override
  Future<Either<Failure, List<SettingsCategoryEntity>>> call(
      NoParams params) async {
    return repository.getCategories();
  }
}
