import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reports_entities.dart';
import '../repositories/reports_repository.dart';

/// Use case to get reports data from repository
class GetReportsData implements UseCase<ReportsData, NoParams> {
  final ReportsRepository repository;

  GetReportsData(this.repository);

  @override
  Future<Either<Failure, ReportsData>> call(NoParams params) async {
    return repository.getReportsData();
  }
}
