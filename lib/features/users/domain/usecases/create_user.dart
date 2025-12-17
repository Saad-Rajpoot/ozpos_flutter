import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

/// Use case for creating a new user
class CreateUser implements UseCase<UserEntity, UserEntity> {
  final UserRepository repository;

  CreateUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UserEntity params) async {
    return repository.createUser(params);
  }
}

