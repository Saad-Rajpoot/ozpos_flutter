import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'data/datasources/auth_remote_datasource.dart';
import '../storage/secure_storage_service.dart';

/// Repository responsible for authenticating users and managing session tokens.
/// Login is performed via [AuthRemoteDataSource] (multipart/form-data); tokens
/// and user data are persisted to SecureStorage and SharedPreferences.
class AuthRepository {
  AuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService secureStorage,
    required SharedPreferences sharedPreferences,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage,
        _sharedPreferences = sharedPreferences;

  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;
  final SharedPreferences _sharedPreferences;

  /// Attempts to authenticate with email and password (multipart/form-data).
  /// On success, prints full response and saves all data fields to SharedPreferences.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        final encoded = const JsonEncoder.withIndent('  ').convert({
          'success': response.success,
          'message': response.message,
          'data': response.data != null
              ? {
                  'id': response.data!.id,
                  'name': response.data!.name,
                  'email': response.data!.email,
                  'role': response.data!.role,
                  'vendor_uuid': response.data!.vendorUuid,
                  'vendor_name': response.data!.vendorName,
                  'branch_uuid': response.data!.branchUuid,
                  'branch_name': response.data!.branchName,
                  'token': response.data!.token,
                }
              : null,
        });
        debugPrint('Login API response:\n$encoded');
      }

      if (!response.success || response.data == null) {
        throw AuthException(
          response.message ?? 'Login failed. Please try again.',
        );
      }

      final data = response.data!;
      if (data.token.isEmpty) {
        throw const AuthException('Authentication response missing token');
      }

      await _secureStorage.saveAccessToken(data.token);

      await _sharedPreferences.setInt(AppConstants.authUserIdKey, data.id);
      await _sharedPreferences.setString(
        AppConstants.authUserNameKey,
        data.name,
      );
      await _sharedPreferences.setString(
        AppConstants.authUserEmailKey,
        data.email,
      );
      await _sharedPreferences.setString(
        AppConstants.authUserRoleKey,
        data.role,
      );
      await _sharedPreferences.setString(
        AppConstants.authVendorUuidKey,
        data.vendorUuid,
      );
      await _sharedPreferences.setString(
        AppConstants.authVendorNameKey,
        data.vendorName,
      );
      await _sharedPreferences.setString(
        AppConstants.authBranchUuidKey,
        data.branchUuid,
      );
      await _sharedPreferences.setString(
        AppConstants.authBranchNameKey,
        data.branchName,
      );
      await _sharedPreferences.setString(
        AppConstants.authTokenPrefKey,
        data.token,
      );

      final userPayload = {
        'id': data.id,
        'name': data.name,
        'email': data.email,
        'role': data.role,
        'vendor_uuid': data.vendorUuid,
        'vendor_name': data.vendorName,
        'branch_uuid': data.branchUuid,
        'branch_name': data.branchName,
      };
      await _sharedPreferences.setString(
        AppConstants.userKey,
        jsonEncode(userPayload),
      );
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint(
          'AuthRepository.login DioException: ${error.message} ${error.response?.data}',
        );
      }
      throw AuthException(_mapDioError(error));
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AuthRepository.login error: $error');
      }
      if (error is AuthException) rethrow;
      throw AuthException(
        error is Exception ? error.toString() : 'Unable to sign in. Please try again.',
      );
    }
  }

  /// Logs out the current user: calls logout API (Bearer token) then clears all session data.
  /// Local session is always cleared even if the API call fails.
  Future<void> logout() async {
    if (kDebugMode) {
      debugPrint('🔓 Logout: calling logout API...');
    }
    try {
      await _remoteDataSource.logout();
      if (kDebugMode) {
        debugPrint('🔓 Logout: API call succeeded.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔓 Logout: API call failed (clearing local anyway): $e');
      }
    }
    await _secureStorage.deleteAllTokens();
    await _sharedPreferences.remove(AppConstants.userKey);
    await _sharedPreferences.remove(AppConstants.authUserIdKey);
    await _sharedPreferences.remove(AppConstants.authUserNameKey);
    await _sharedPreferences.remove(AppConstants.authUserEmailKey);
    await _sharedPreferences.remove(AppConstants.authUserRoleKey);
    await _sharedPreferences.remove(AppConstants.authVendorUuidKey);
    await _sharedPreferences.remove(AppConstants.authVendorNameKey);
    await _sharedPreferences.remove(AppConstants.authBranchUuidKey);
    await _sharedPreferences.remove(AppConstants.authBranchNameKey);
    await _sharedPreferences.remove(AppConstants.authTokenPrefKey);
    if (kDebugMode) {
      debugPrint('🔓 Logout: local session cleared.');
    }
  }

  /// Returns true if a valid access token exists.
  Future<bool> hasActiveSession() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  String _mapDioError(DioException error) {
    if (error.response?.statusCode == 401) {
      return 'Invalid email or password';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Unable to reach the server. Check your connection.';
    }
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'] as String;
    }
    return 'Authentication failed. Please try again.';
  }
}

/// Thrown when authentication fails.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}
