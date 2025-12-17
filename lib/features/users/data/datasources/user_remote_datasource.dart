import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import 'user_data_source.dart';

/// Remote data source for user operations
class UserRemoteDataSourceImpl implements UserDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<UserEntity>> getUsers() async {
    try {
      final response = await apiClient.get('/users');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> jsonData = response.data as List<dynamic>;
        return jsonData.map((userData) {
          final userModel = UserModel.fromJson(
            userData as Map<String, dynamic>,
          );
          return userModel.toEntity();
        }).toList();
      }
      throw ServerException(message: 'Failed to load users');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to load users: $e');
    }
  }

  @override
  Future<UserEntity> getUserById(String userId) async {
    try {
      final response = await apiClient.get('/users/$userId');
      if (response.statusCode == 200 && response.data != null) {
        final userModel = UserModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return userModel.toEntity();
      }
      throw ServerException(message: 'User not found');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to load user: $e');
    }
  }

  @override
  Future<UserEntity> createUser(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final response = await apiClient.post(
        '/users',
        data: userModel.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final userModel = UserModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return userModel.toEntity();
      }
      throw ServerException(message: 'Failed to create user');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to create user: $e');
    }
  }

  @override
  Future<UserEntity> updateUser(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final response = await apiClient.put(
        '/users/${user.id}',
        data: userModel.toJson(),
      );
      if (response.statusCode == 200) {
        final userModel = UserModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return userModel.toEntity();
      }
      throw ServerException(message: 'Failed to update user');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      final response = await apiClient.delete('/users/$userId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(message: 'Failed to delete user');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to delete user: $e');
    }
  }
}

