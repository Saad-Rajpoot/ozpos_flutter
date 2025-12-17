import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/addon_management_entities.dart';
import '../repositories/addon_repository.dart';

/// Use case to get addon categories from repository
class GetAddonCategories implements UseCase<List<AddonCategory>, NoParams> {
  final AddonRepository repository;

  GetAddonCategories(this.repository);

  @override
  Future<Either<Failure, List<AddonCategory>>> call(NoParams params) async {
    return repository.getAddonCategories();
  }
}
