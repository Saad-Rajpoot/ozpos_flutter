import 'package:dartz/dartz.dart';

import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/customer_display_entity.dart';
import '../repositories/customer_display_repository.dart';

class GetCustomerDisplay implements UseCase<CustomerDisplayEntity, NoParams> {
  final CustomerDisplayRepository repository;

  GetCustomerDisplay({required this.repository});

  @override
  Future<Either<Failure, CustomerDisplayEntity>> call(NoParams params) {
    return repository.getDisplayContent();
  }
}
