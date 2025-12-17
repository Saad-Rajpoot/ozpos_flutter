import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

/// Use case for updating an existing user
class UpdateUser implements UseCase<UserEntity, UserEntity> {
  final UserRepository repository;

  UpdateUser(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UserEntity params) async {
    return repository.updateUser(params);
  }
}

