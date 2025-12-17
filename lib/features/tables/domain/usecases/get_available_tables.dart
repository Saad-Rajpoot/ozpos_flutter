import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/table_entity.dart';
import '../repositories/table_repository.dart';

/// Use case to get available tables from repository for move operations
class GetMoveAvailableTables implements UseCase<List<TableEntity>, NoParams> {
  final TableRepository repository;

  GetMoveAvailableTables(this.repository);

  @override
  Future<Either<Failure, List<TableEntity>>> call(NoParams params) async {
    return repository.getMoveAvailableTables();
  }
}
