import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../navigation/navigation_service.dart';
import '../navigation/app_router.dart';

/// API Client for making HTTP requests
class ApiClient {
  late final Dio _dio;
  final SharedPreferences _sharedPreferences;
  final String _baseUrl;

  ApiClient({required SharedPreferences sharedPreferences, String? baseUrl})
      : _sharedPreferences = sharedPreferences,
        _baseUrl = baseUrl ?? AppConstants.baseUrl {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  /// Setup interceptors for authentication, retry, and logging
  void _setupInterceptors() {
    // Auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _sharedPreferences.getString(AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Handle token refresh or logout
            await _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );

    // Logging interceptor (only in debug mode)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }
  }

  /// Handle unauthorized access
  ///
  /// Clears all authentication data and navigates to dashboard
  /// when a 401 (Unauthorized) response is received.
  Future<void> _handleUnauthorized() async {
    try {
      // Clear all auth-related data
      await _sharedPreferences.remove(AppConstants.tokenKey);
      await _sharedPreferences.remove(AppConstants.userKey);

      // Use NavigationService for safe, context-free navigation
      // Check if navigator is ready before attempting navigation
      if (NavigationService.navigatorKey.currentState != null &&
          NavigationService.navigatorKey.currentContext != null) {
        // Show snackbar message using NavigationService
        NavigationService.showSnackBar(
          'Session expired. Please login again.',
          duration: const Duration(seconds: 3),
        );

        // Navigate to dashboard and clear all previous routes
        // Note: If a login route exists in the future, replace AppRouter.dashboard
        // with AppRouter.login to redirect to login screen
        await NavigationService.pushAndClearStack(AppRouter.dashboard);
      }
    } catch (e) {
      // Log error but don't throw - this is called from an interceptor
      // and we don't want to break the error handling flow
      if (kDebugMode) {
        debugPrint('Error handling unauthorized access: $e');
      }
    }
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
