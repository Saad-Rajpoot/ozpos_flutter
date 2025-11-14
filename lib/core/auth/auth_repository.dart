import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../network/certificate_pinner.dart';
import '../storage/secure_storage_service.dart';

/// Repository responsible for authenticating users and managing session tokens.
class AuthRepository {
  AuthRepository({
    required SecureStorageService secureStorage,
    required SharedPreferences sharedPreferences,
  })  : _secureStorage = secureStorage,
        _sharedPreferences = sharedPreferences {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.instance.baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (AppConfig.instance.isCertificatePinningEnabled) {
      final pinner = CertificatePinner(AppConfig.instance.certificatePins);
      _dio.httpClientAdapter = pinner.createPinnedAdapter();
    }
  }

  late final Dio _dio;
  final SecureStorageService _secureStorage;
  final SharedPreferences _sharedPreferences;

  /// Attempts to authenticate the user with provided credentials.
  ///
  /// On success, access and refresh tokens are stored securely.
  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode != 200 || response.data == null) {
        throw const AuthException('Invalid username or password');
      }

      final data = response.data;
      final accessToken = _extractToken(data);
      final refreshToken = _extractRefreshToken(data);

      if (accessToken == null || accessToken.isEmpty) {
        throw const AuthException('Authentication response missing token');
      }

      await _secureStorage.saveAccessToken(accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _secureStorage.saveRefreshToken(refreshToken);
      }

      final userPayload = data['user'] ?? data['data']?['user'];
      if (userPayload != null) {
        await _sharedPreferences.setString(
          AppConstants.userKey,
          jsonEncode(userPayload),
        );
      }
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint(
            'AuthRepository.login DioException: ${error.message} ${error.response?.data}');
      }
      throw AuthException(_mapDioError(error));
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AuthRepository.login error: $error');
      }
      if (error is AuthException) rethrow;
      throw const AuthException('Unable to sign in. Please try again.');
    }
  }

  /// Logs out the current user and clears all session data.
  Future<void> logout() async {
    await _secureStorage.deleteAllTokens();
    await _sharedPreferences.remove(AppConstants.userKey);
  }

  /// Returns true if a valid access token exists.
  Future<bool> hasActiveSession() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Extracts access token from API response.
  String? _extractToken(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['token'] ??
          responseData['access_token'] ??
          responseData['data']?['token'] ??
          responseData['data']?['access_token'];
    }
    return null;
  }

  /// Extracts refresh token from API response.
  String? _extractRefreshToken(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['refresh_token'] ??
          responseData['data']?['refresh_token'];
    }
    return null;
  }

  String _mapDioError(DioException error) {
    if (error.response?.statusCode == 401) {
      return 'Invalid username or password';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Unable to reach the server. Check your connection.';
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

