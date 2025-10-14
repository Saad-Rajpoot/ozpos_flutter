import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/combo_slot_entity.dart';
import '../repositories/combo_repository.dart';

/// Use case to get combo slots from repository
class GetComboSlots implements UseCase<List<ComboSlotEntity>, NoParams> {
  final ComboRepository repository;

  GetComboSlots(this.repository);

  @override
  Future<Either<Failure, List<ComboSlotEntity>>> call(NoParams params) async {
    return repository.getComboSlots();
  }
}
