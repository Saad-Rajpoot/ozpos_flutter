import '../../domain/entities/user_entity.dart';

/// Abstract data source for user operations
abstract class UserDataSource {
  /// Get all users
  Future<List<UserEntity>> getUsers();

  /// Get user by ID
  Future<UserEntity> getUserById(String userId);

  /// Create a new user
  Future<UserEntity> createUser(UserEntity user);

  /// Update an existing user
  Future<UserEntity> updateUser(UserEntity user);

  /// Delete a user
  Future<void> deleteUser(String userId);
}

