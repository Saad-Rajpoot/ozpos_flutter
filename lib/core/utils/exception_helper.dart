import 'package:dio/dio.dart';
import '../errors/exceptions.dart';
import '../models/paginated_response.dart';

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

      // Try to extract detailed error message from response body
      String? detailedMessage;
      if (e.response?.data is Map<String, dynamic>) {
        final errorData = e.response!.data as Map<String, dynamic>;
        detailedMessage = errorData['message'] ??
            errorData['error'] ??
            errorData['errors']?.toString() ??
            errorData['data']?['message'];
      } else if (e.response?.data is String) {
        detailedMessage = e.response!.data as String;
      }

      return ServerException(
        message: detailedMessage ??
            'Server error during $operation ($statusCode): $statusMessage',
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

  /// Validate and extract paginated response from API response
  ///
  /// [responseData] - The response.data from API call
  /// [fromJson] - Function to convert JSON item to T
  /// [operation] - Description of the operation for error messages
  /// [dataKey] - Key containing the data array (default: 'data')
  /// [pageKey] - Key containing current page (default: 'current_page')
  /// [totalPagesKey] - Key containing total pages (default: 'last_page')
  /// [totalItemsKey] - Key containing total items (default: 'total')
  /// [perPageKey] - Key containing items per page (default: 'per_page')
  ///
  /// Returns PaginatedResponse<T> or throws ServerException if invalid
  static PaginatedResponse<T> validatePaginatedResponse<T>(
    dynamic responseData,
    T Function(Map<String, dynamic>) fromJson,
    String operation, {
    String dataKey = 'data',
    String pageKey = 'current_page',
    String totalPagesKey = 'last_page',
    String totalItemsKey = 'total',
    String perPageKey = 'per_page',
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

    try {
      return PaginatedResponse<T>.fromJson(
        responseData,
        fromJson,
        dataKey: dataKey,
        pageKey: pageKey,
        totalPagesKey: totalPagesKey,
        totalItemsKey: totalItemsKey,
        perPageKey: perPageKey,
      );
    } catch (e) {
      throw ServerException(
        message: 'Invalid paginated response format during $operation: $e',
      );
    }
  }
}
