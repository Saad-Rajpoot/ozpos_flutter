import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../navigation/navigation_service.dart';
import '../navigation/app_router.dart';
import 'retry_interceptor.dart';

/// API Client for making HTTP requests
class ApiClient {
  late final Dio _dio;
  final SharedPreferences _sharedPreferences;
  final String _baseUrl;
  final Map<String, CancelToken> _trackedCancelTokens = {};

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

  /// Creates a new [CancelToken] and optionally tracks it with a [requestKey].
  ///
  /// When [requestKey] is provided, any existing tracked token with the same key
  /// is cancelled before storing the new one. Use this helper from blocs or
  /// repositories to tie a network request to a specific lifecycle.
  CancelToken createTrackedCancelToken({
    String? requestKey,
    dynamic cancelReason,
  }) {
    final cancelToken = CancelToken();
    if (requestKey != null) {
      _trackedCancelTokens.remove(requestKey)?.cancel(
            cancelReason ?? 'Replaced by a new request: $requestKey',
          );
      _trackedCancelTokens[requestKey] = cancelToken;
    }
    return cancelToken;
  }

  /// Cancels a tracked request identified by [requestKey].
  void cancelTrackedRequest(
    String requestKey, {
    dynamic reason = 'Cancelled by lifecycle change',
  }) {
    _trackedCancelTokens.remove(requestKey)?.cancel(reason);
  }

  /// Cancels every tracked request.
  void cancelAllTrackedRequests({
    dynamic reason = 'Cancelled by ApiClient.cancelAllTrackedRequests',
  }) {
    for (final entry in _trackedCancelTokens.entries) {
      entry.value.cancel(reason);
    }
    _trackedCancelTokens.clear();
  }

  CancelToken? _resolveCancelToken({
    CancelToken? overrideToken,
    String? requestKey,
  }) {
    if (overrideToken != null) {
      if (requestKey != null) {
        _trackedCancelTokens[requestKey] = overrideToken;
      }
      return overrideToken;
    }

    if (requestKey != null) {
      return _trackedCancelTokens.putIfAbsent(
        requestKey,
        CancelToken.new,
      );
    }

    return null;
  }

  /// Setup interceptors for authentication, retry, and logging
  void _setupInterceptors() {
    // Retry interceptor - should be added first to handle retries before other interceptors
    // Pass the Dio instance so retries can use the same instance with all interceptors
    _dio.interceptors.add(
      RetryInterceptor(
        maxRetries: AppConstants.maxRetries,
        retryDelay: AppConstants.retryDelay,
        useExponentialBackoff: false, // Set to true for exponential backoff
        dio: _dio,
      ),
    );

    // Auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Initialize retry count if not present
          options.extra['retryCount'] = options.extra['retryCount'] ?? 0;
          // Store Dio instance reference for retry interceptor
          options.extra['_dio'] = _dio;

          final token = _sharedPreferences.getString(AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Handle token refresh or logout
            // Don't retry on 401 errors - handle immediately
            await _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );

    // Logging interceptor (only in debug mode) - should be last
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
          duration: AppConstants.snackbarDefaultDuration,
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
    CancelToken? cancelToken,
    String? requestKey,
  }) async {
    final resolvedToken = _resolveCancelToken(
      overrideToken: cancelToken,
      requestKey: requestKey,
    );
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: resolvedToken,
      );
    } finally {
      if (requestKey != null) {
        _trackedCancelTokens.remove(requestKey);
      }
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? requestKey,
  }) async {
    final resolvedToken = _resolveCancelToken(
      overrideToken: cancelToken,
      requestKey: requestKey,
    );
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: resolvedToken,
      );
    } finally {
      if (requestKey != null) {
        _trackedCancelTokens.remove(requestKey);
      }
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? requestKey,
  }) async {
    final resolvedToken = _resolveCancelToken(
      overrideToken: cancelToken,
      requestKey: requestKey,
    );
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: resolvedToken,
      );
    } finally {
      if (requestKey != null) {
        _trackedCancelTokens.remove(requestKey);
      }
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? requestKey,
  }) async {
    final resolvedToken = _resolveCancelToken(
      overrideToken: cancelToken,
      requestKey: requestKey,
    );
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: resolvedToken,
      );
    } finally {
      if (requestKey != null) {
        _trackedCancelTokens.remove(requestKey);
      }
    }
  }
}
