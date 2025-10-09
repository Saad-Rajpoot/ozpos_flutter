import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/docket_management_entities.dart';
import '../repositories/docket_repository.dart';

/// Use case to get dockets from repository
class GetDockets implements UseCase<List<DocketEntity>, NoParams> {
  final DocketRepository repository;

  GetDockets(this.repository);

  @override
  Future<Either<Failure, List<DocketEntity>>> call(NoParams params) async {
    return repository.getDockets();
  }
}
