import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/table_entity.dart';
import '../repositories/table_repository.dart';

/// Use case to get tables from repository
class GetTables implements UseCase<List<TableEntity>, NoParams> {
  final TableRepository repository;

  GetTables(this.repository);

  @override
  Future<Either<Failure, List<TableEntity>>> call(NoParams params) async {
    return repository.getTables();
  }
}
