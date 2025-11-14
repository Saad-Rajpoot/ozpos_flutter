import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Retry interceptor for Dio that automatically retries failed requests
///
/// Retries are performed for:
/// - Network errors (connection timeout, receive timeout, send timeout)
/// - Connection errors
/// - Server errors (500, 502, 503, 504)
///
/// Retries are NOT performed for:
/// - Client errors (400, 401, 403, 404)
/// - Requests that have already exceeded max retries
class RetryInterceptor extends Interceptor {
  /// Maximum number of retries
  final int maxRetries;

  /// Delay between retries
  final Duration retryDelay;

  /// Whether to use exponential backoff
  final bool useExponentialBackoff;

  /// Base multiplier for exponential backoff
  final double exponentialBase;

  /// Dio instance to use for retries
  final Dio? dio;

  RetryInterceptor({
    this.maxRetries = AppConstants.maxRetries,
    this.retryDelay = AppConstants.retryDelay,
    this.useExponentialBackoff = false,
    this.exponentialBase = 2.0,
    this.dio,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Skip retry if this is a retry attempt (to prevent loops)
    if (err.requestOptions.extra['_skipRetryInterceptor'] == true) {
      handler.next(err);
      return;
    }

    // Get current retry count from request options
    final retryCount = (err.requestOptions.extra['retryCount'] as int?) ?? 0;

    // Check if we should retry this error
    if (retryCount < maxRetries && _shouldRetry(err)) {
      // Increment retry count
      final newRetryCount = retryCount + 1;
      err.requestOptions.extra['retryCount'] = newRetryCount;

      // Calculate delay (exponential backoff or fixed delay)
      final delay = _calculateDelay(newRetryCount);

      if (kDebugMode) {
        debugPrint(
          '🔄 Retrying request (attempt $newRetryCount/$maxRetries): '
          '${err.requestOptions.path} after ${delay.inMilliseconds}ms',
        );
      }

      // Wait before retrying
      await Future.delayed(delay);

      // Use the provided Dio instance or get from request options
      final dioInstance = dio ?? (err.requestOptions.extra['_dio'] as Dio?);

      if (dioInstance == null) {
        // If no Dio instance available, forward the error
        handler.next(err);
        return;
      }

      try {
        // Create a new RequestOptions with updated retry count and skip flag
        final retryOptions = RequestOptions(
          method: err.requestOptions.method,
          path: err.requestOptions.path,
          queryParameters: err.requestOptions.queryParameters,
          data: err.requestOptions.data,
          headers: Map<String, dynamic>.from(err.requestOptions.headers),
          extra: Map<String, dynamic>.from(err.requestOptions.extra)
            ..['retryCount'] = newRetryCount
            ..['_skipRetryInterceptor'] = true, // Prevent retry loop
          contentType: err.requestOptions.contentType,
          responseType: err.requestOptions.responseType,
          validateStatus: err.requestOptions.validateStatus,
          receiveDataWhenStatusError:
              err.requestOptions.receiveDataWhenStatusError,
          followRedirects: err.requestOptions.followRedirects,
          cancelToken: err.requestOptions.cancelToken,
          baseUrl: err.requestOptions.baseUrl,
          onReceiveProgress: err.requestOptions.onReceiveProgress,
          onSendProgress: err.requestOptions.onSendProgress,
          listFormat: err.requestOptions.listFormat,
        );

        // Retry using fetch which will still go through other interceptors
        // but the skip flag prevents this interceptor from retrying again
        final response = await dioInstance.fetch(retryOptions);

        // Success - resolve with the response
        handler.resolve(response);
        return;
      } on DioException catch (e) {
        // Check if this was a retry attempt (had skip flag)
        final wasRetryAttempt =
            e.requestOptions.extra.remove('_skipRetryInterceptor') == true;

        // If this was a retry attempt and it failed, check if we should retry again
        if (wasRetryAttempt && newRetryCount < maxRetries && _shouldRetry(e)) {
          // Update retry count - use newRetryCount which is already incremented
          // The recursive call will increment it again if needed
          e.requestOptions.extra['retryCount'] = newRetryCount;
          // Recursively retry (the skip flag was removed, so it will try again)
          return onError(e, handler);
        }

        // Max retries reached, error shouldn't be retried, or this wasn't a retry attempt
        // Forward the error to the next handler
        handler.reject(e);
        return;
      } catch (e) {
        // Non-DioException - forward the original error
        if (kDebugMode) {
          debugPrint('❌ Non-DioException during retry: $e');
        }
        handler.reject(err);
        return;
      }
    }

    // Don't retry - forward the error to the next handler
    handler.next(err);
  }

  /// Determines if an error should be retried
  bool _shouldRetry(DioException err) {
    // Don't retry on client errors (4xx) except for specific cases
    if (err.response != null) {
      final statusCode = err.response!.statusCode;

      // Don't retry on client errors
      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        // Exception: Retry on 408 (Request Timeout) and 429 (Too Many Requests)
        if (statusCode == 408 || statusCode == 429) {
          return true;
        }
        return false;
      }

      // Retry on server errors (5xx)
      if (statusCode != null && statusCode >= 500) {
        return true;
      }
    }

    // Retry on network-related errors
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        // Already handled above
        return false;
      case DioExceptionType.cancel:
        // Don't retry cancelled requests
        return false;
      case DioExceptionType.unknown:
        // Check if it's a network error
        if (err.error != null) {
          final errorMessage = err.error.toString().toLowerCase();
          if (errorMessage.contains('socket') ||
              errorMessage.contains('network') ||
              errorMessage.contains('connection') ||
              errorMessage.contains('timeout')) {
            return true;
          }
        }
        return false;
      case DioExceptionType.badCertificate:
        // Don't retry on certificate errors
        return false;
    }
  }

  /// Calculates the delay before retrying
  ///
  /// Uses exponential backoff if enabled, otherwise uses fixed delay
  Duration _calculateDelay(int retryCount) {
    if (useExponentialBackoff) {
      // Exponential backoff: delay = baseDelay * (exponentialBase ^ (retryCount - 1))
      // Example: retryCount=1 -> delay=baseDelay, retryCount=2 -> delay=baseDelay*base, etc.
      final exponentialMultiplier = math.pow(exponentialBase, retryCount - 1);
      final delayMs =
          (retryDelay.inMilliseconds * exponentialMultiplier).round();
      return Duration(milliseconds: delayMs.clamp(100, 30000)); // Cap at 30s
    } else {
      // Fixed delay
      return retryDelay;
    }
  }
}
