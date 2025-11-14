import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../config/app_config.dart';
import '../navigation/navigation_service.dart';
import '../navigation/app_router.dart';
import 'retry_interceptor.dart';

/// Helper class to track pending requests during token refresh
class _PendingRequest {
  final Completer<bool> completer;

  _PendingRequest({required this.completer});
}

/// API Client for making HTTP requests
class ApiClient {
  late final Dio _dio;
  final SharedPreferences _sharedPreferences;
  final String _baseUrl;
  final Map<String, CancelToken> _trackedCancelTokens = {};

  // Token refresh lock to prevent concurrent refresh requests
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

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
        useExponentialBackoff:
            AppConfig.instance.environment == AppEnvironment.production,
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
            // Skip refresh if this is already a refresh request to avoid infinite loop
            if (error.requestOptions.path == AppConstants.refreshEndpoint) {
              // Refresh failed, logout
              await _handleUnauthorized();
              handler.next(error);
              return;
            }

            // Attempt token refresh
            final refreshed = await _attemptTokenRefresh();

            if (refreshed) {
              // Retry the original request with new token
              try {
                final newToken =
                    _sharedPreferences.getString(AppConstants.tokenKey);
                if (newToken != null) {
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newToken';
                  // Create a new request options to avoid modifying the original
                  final opts = Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                    extra: error.requestOptions.extra,
                    contentType: error.requestOptions.contentType,
                    responseType: error.requestOptions.responseType,
                    validateStatus: error.requestOptions.validateStatus,
                    receiveDataWhenStatusError:
                        error.requestOptions.receiveDataWhenStatusError,
                    followRedirects: error.requestOptions.followRedirects,
                    listFormat: error.requestOptions.listFormat,
                  );

                  final response = await _dio.request(
                    error.requestOptions.path,
                    data: error.requestOptions.data,
                    queryParameters: error.requestOptions.queryParameters,
                    options: opts,
                    cancelToken: error.requestOptions.cancelToken,
                  );

                  handler.resolve(response);
                  return;
                } else {
                  // Token was not saved properly after refresh
                  if (kDebugMode) {
                    debugPrint('⚠️ New token not found after refresh');
                  }
                  await _handleUnauthorized();
                  handler.next(error);
                  return;
                }
              } on DioException catch (e) {
                // If retry fails with 401 again, logout
                if (e.response?.statusCode == 401) {
                  if (kDebugMode) {
                    debugPrint('❌ Retry failed with 401 after token refresh');
                  }
                  await _handleUnauthorized();
                  handler.next(e);
                  return;
                } else {
                  // Other errors should propagate normally
                  handler.reject(e);
                  return;
                }
              } catch (e) {
                // Unexpected error during retry
                if (kDebugMode) {
                  debugPrint('❌ Unexpected error during request retry: $e');
                }
                handler.next(error);
                return;
              }
            } else {
              // Refresh failed, logout
              await _handleUnauthorized();
            }
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

  /// Attempts to refresh the access token using the refresh token
  ///
  /// Returns true if refresh was successful, false otherwise
  /// Handles concurrent refresh requests by queuing them
  Future<bool> _attemptTokenRefresh() async {
    // If already refreshing, wait for the ongoing refresh to complete
    if (_isRefreshing) {
      final completer = Completer<bool>();
      _pendingRequests.add(_PendingRequest(completer: completer));
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final refreshToken =
          _sharedPreferences.getString(AppConstants.refreshTokenKey);

      if (refreshToken == null || refreshToken.isEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ No refresh token available for token refresh');
        }
        _isRefreshing = false;
        _completePendingRequests(false);
        return false;
      }

      if (kDebugMode) {
        debugPrint('🔄 Attempting to refresh access token...');
      }

      // Create a new Dio instance without interceptors to avoid infinite loop
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: AppConstants.connectionTimeout,
          receiveTimeout: AppConstants.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Make refresh request
      final response = await refreshDio.post(
        AppConstants.refreshEndpoint,
        data: {
          'refresh_token': refreshToken,
        },
      );

      // Parse response - adjust based on your backend response format
      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        // Handle different response formats
        String? newToken;
        String? newRefreshToken;

        if (responseData is Map<String, dynamic>) {
          // Try common response formats
          newToken = responseData['token'] ??
              responseData['access_token'] ??
              responseData['data']?['token'] ??
              responseData['data']?['access_token'];

          newRefreshToken = responseData['refresh_token'] ??
              responseData['data']?['refresh_token'];
        }

        if (newToken != null && newToken.isNotEmpty) {
          // Save new tokens
          await _sharedPreferences.setString(AppConstants.tokenKey, newToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await _sharedPreferences.setString(
                AppConstants.refreshTokenKey, newRefreshToken);
          }

          if (kDebugMode) {
            debugPrint('✅ Token refreshed successfully');
          }

          _isRefreshing = false;
          _completePendingRequests(true);
          return true;
        } else {
          if (kDebugMode) {
            debugPrint('❌ Token refresh response missing token field');
          }
          _isRefreshing = false;
          _completePendingRequests(false);
          return false;
        }
      } else {
        if (kDebugMode) {
          debugPrint(
              '❌ Token refresh failed with status: ${response.statusCode}');
        }
        _isRefreshing = false;
        _completePendingRequests(false);
        return false;
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Token refresh error: ${e.message}');
        if (e.response != null) {
          debugPrint('   Status: ${e.response?.statusCode}');
          debugPrint('   Data: ${e.response?.data}');
        }
      }
      _isRefreshing = false;
      _completePendingRequests(false);
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error during token refresh: $e');
      }
      _isRefreshing = false;
      _completePendingRequests(false);
      return false;
    }
  }

  /// Completes all pending requests waiting for token refresh
  void _completePendingRequests(bool success) {
    for (final pending in _pendingRequests) {
      pending.completer.complete(success);
    }
    _pendingRequests.clear();
  }

  /// Handle unauthorized access
  ///
  /// Clears all authentication data and navigates to dashboard
  /// when a 401 (Unauthorized) response is received and token refresh fails.
  Future<void> _handleUnauthorized() async {
    try {
      // Clear all auth-related data
      await _sharedPreferences.remove(AppConstants.tokenKey);
      await _sharedPreferences.remove(AppConstants.refreshTokenKey);
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

  /// PATCH request
  ///
  /// Used for partial updates to resources.
  /// Unlike PUT which replaces the entire resource, PATCH allows updating only specific fields.
  ///
  /// **When to use PATCH:**
  /// - Updating only specific fields (e.g., status, price, settings)
  /// - Partial updates to minimize data transfer
  /// - Backend expects partial updates
  ///
  /// **Example:**
  /// ```dart
  /// // Update only order status
  /// await apiClient.patch(
  ///   '/orders/123',
  ///   data: {'status': 'completed'},
  /// );
  ///
  /// // Update printer settings
  /// await apiClient.patch(
  ///   '/printers/1',
  ///   data: {'is_default': true, 'connection': 'network'},
  /// );
  /// ```
  ///
  /// See `docs/PATCH_METHOD_USAGE.md` for detailed usage examples.
  Future<Response> patch(
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
      return await _dio.patch(
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
