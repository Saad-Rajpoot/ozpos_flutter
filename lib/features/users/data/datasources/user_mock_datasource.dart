import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import 'user_data_source.dart';

/// Mock user data source that loads from JSON files
class UserMockDataSourceImpl implements UserDataSource {
  static const _successFile = 'assets/users_data/users.json';
  static const _errorFile = 'assets/users_data/users_error.json';

  @override
  Future<List<UserEntity>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final jsonString = await rootBundle.loadString(_successFile);
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((userData) {
        final userModel = UserModel.fromJson(
          userData as Map<String, dynamic>,
        );
        return userModel.toEntity();
      }).toList();
    } catch (e) {
      try {
        final errorJsonString = await rootBundle.loadString(_errorFile);
        final Map<String, dynamic> errorData = json.decode(errorJsonString);
        throw CacheException(
          message: errorData['message'] ?? 'Failed to load users',
        );
      } catch (errorLoadingError) {
        throw CacheException(message: 'Failed to load users: $e');
      }
    }
  }

  @override
  Future<UserEntity> getUserById(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final users = await getUsers();
    return users.firstWhere(
      (u) => u.id == userId,
      orElse: () => throw Exception('User not found'),
    );
  }

  @override
  Future<UserEntity> createUser(UserEntity user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real implementation, this would save to backend
    // For mock, just return the user with a generated ID
    return user.copyWith(
      id: user.id.isEmpty ? 'user_${DateTime.now().millisecondsSinceEpoch}' : user.id,
    );
  }

  @override
  Future<UserEntity> updateUser(UserEntity user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real implementation, this would update the backend
    return user;
  }

  @override
  Future<void> deleteUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real implementation, this would delete from backend
  }
}

