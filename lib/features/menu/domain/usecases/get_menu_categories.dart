import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/menu_category_entity.dart';
import '../repositories/menu_repository.dart';

/// Get menu categories use case
class GetMenuCategories implements UseCase<List<MenuCategoryEntity>, NoParams> {
  final MenuRepository repository;

  GetMenuCategories({required this.repository});

  @override
  Future<Either<Failure, List<MenuCategoryEntity>>> call(NoParams params) async {
    return await repository.getMenuCategories();
  }
}
