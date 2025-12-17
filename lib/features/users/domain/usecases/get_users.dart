import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

/// Use case for getting all users
class GetUsers implements UseCase<List<UserEntity>, NoParams> {
  final UserRepository repository;

  GetUsers(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(NoParams params) async {
    return repository.getUsers();
  }
}

