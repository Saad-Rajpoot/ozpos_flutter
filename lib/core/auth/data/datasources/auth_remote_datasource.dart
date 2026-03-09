import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/login_response_model.dart';

/// Remote data source for authentication API (login, logout).
/// Login uses multipart/form-data; logout uses POST with Bearer token.
abstract class AuthRemoteDataSource {
  /// POST auth/login with multipart/form-data (email, password).
  /// Returns [LoginResponseModel] on success.
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  /// POST auth/logout with Authorization: Bearer token.
  /// Call with valid token to invalidate session on server.
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    final formData = FormData.fromMap(<String, dynamic>{
      'email': email,
      'password': password,
    });

    // Relative path: baseUrl is e.g. https://v3.ozfoodz.com.au/api/pos/
    const path = 'auth/login';
    if (kDebugMode) {
      final uri = _dio.options.baseUrl.isEmpty
          ? path
          : '${_dio.options.baseUrl}$path';
      debugPrint('Auth login request URL: $uri');
    }
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: <String, dynamic>{'Accept': 'application/json'},
      ),
    );

    if (response.data == null) {
      throw Exception('Login response body is null');
    }

    return LoginResponseModel.fromJson(response.data!);
  }

  @override
  Future<void> logout() async {
    const path = 'auth/logout';
    final url = _dio.options.baseUrl.isEmpty
        ? path
        : '${_dio.options.baseUrl}$path';
    if (kDebugMode) {
      debugPrint('🔓 Logout API request: POST $url (Authorization: Bearer <token> from storage)');
    }
    final response = await _dio.post<dynamic>(
      path,
      options: Options(headers: {'Accept': 'application/json'}),
    );
    if (kDebugMode) {
      debugPrint(
        '🔓 Logout API response: statusCode=${response.statusCode}, '
        'data=${response.data?.toString() ?? 'null'}',
      );
    }
  }
}
