import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

/// Global exception helper for handling DioException and other API errors
/// This provides a standardized error handling pattern across all data sources
class ExceptionHelper {
  /// Handle DioException and convert to appropriate exceptions
  ///
  /// [e] - The DioException to handle
  /// [operation] - Description of the operation being performed (e.g., 'fetching combos')
  ///
  /// Returns appropriate exception based on error type:
  /// - NetworkException for connection/timeout errors
  /// - ServerException for server errors (4xx, 5xx)
  static Exception handleDioException(DioException e, String operation) {
    // Handle timeout errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkException(
        message:
            'Request timeout during $operation: ${e.message ?? 'Unknown timeout error'}',
      );
    }

    // Handle connection errors
    if (e.type == DioExceptionType.connectionError) {
      return NetworkException(
        message:
            'Connection error during $operation: ${e.message ?? 'Unable to connect to server'}',
      );
    }

    // Handle server errors (4xx, 5xx)
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final statusMessage = e.response?.statusMessage ?? 'Unknown error';

      return ServerException(
        message: 'Server error during $operation ($statusCode): $statusMessage',
      );
    }

    // Handle other DioException types
    return ServerException(
      message:
          'Error during $operation: ${e.message ?? 'Unknown error occurred'}',
    );
  }

  /// Validate and extract data from API response
  ///
  /// [responseData] - The response.data from API call
  /// [dataKey] - The key to extract from response (default: 'data')
  /// [operation] - Description of the operation for error messages
  ///
  /// Returns the extracted data or throws ServerException if invalid
  static dynamic validateResponseData(
    dynamic responseData,
    String operation, {
    String dataKey = 'data',
  }) {
    if (responseData == null) {
      throw ServerException(
        message:
            'Invalid response format during $operation: response data is null',
      );
    }

    if (responseData is! Map<String, dynamic>) {
      throw ServerException(
        message:
            'Invalid response format during $operation: expected Map, got ${responseData.runtimeType}',
      );
    }

    if (!responseData.containsKey(dataKey)) {
      throw ServerException(
        message:
            'Invalid response format during $operation: missing key "$dataKey"',
      );
    }

    final data = responseData[dataKey];
    if (data == null) {
      throw ServerException(
        message:
            'Invalid response format during $operation: "$dataKey" is null',
      );
    }

    return data;
  }

  /// Validate and extract list data from API response
  ///
  /// [responseData] - The response.data from API call
  /// [dataKey] - The key to extract from response (default: 'data')
  /// [operation] - Description of the operation for error messages
  ///
  /// Returns the extracted list or throws ServerException if invalid
  static List<dynamic> validateListResponse(
    dynamic responseData,
    String operation, {
    String dataKey = 'data',
  }) {
    final data =
        validateResponseData(responseData, operation, dataKey: dataKey);

    if (data is! List) {
      throw ServerException(
        message:
            'Invalid response format during $operation: expected List, got ${data.runtimeType}',
      );
    }

    return data;
  }
}
