import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Repository interface for user operations
abstract class UserRepository {
  /// Get all users
  Future<Either<Failure, List<UserEntity>>> getUsers();

  /// Get user by ID
  Future<Either<Failure, UserEntity>> getUserById(String userId);

  /// Create a new user
  Future<Either<Failure, UserEntity>> createUser(UserEntity user);

  /// Update an existing user
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user);

  /// Delete a user
  Future<Either<Failure, void>> deleteUser(String userId);
}

