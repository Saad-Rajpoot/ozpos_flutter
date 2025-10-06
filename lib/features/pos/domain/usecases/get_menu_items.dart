import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/menu_item_entity.dart';
import '../repositories/menu_repository.dart';

/// Get menu items use case
class GetMenuItems implements UseCase<List<MenuItemEntity>, NoParams> {
  final MenuRepository repository;

  GetMenuItems({required this.repository});

  @override
  Future<Either<Failure, List<MenuItemEntity>>> call(NoParams params) async {
    return await repository.getMenuItems();
  }
}
