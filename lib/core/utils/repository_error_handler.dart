import 'package:dartz/dartz.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../network/network_info.dart';

/// Repository error handler utility
/// Provides a standardized error handling pattern across all repository implementations
class RepositoryErrorHandler {
  /// Execute a repository operation with standardized error handling
  ///
  /// This method handles:
  /// - Network connectivity checks
  /// - Exception to failure conversion
  /// - Consistent error messages
  ///
  /// [operation] - The async operation to execute
  /// [networkInfo] - Network info for connectivity checks
  /// [operationName] - Name of the operation (for error messages)
  /// [skipNetworkCheck] - Whether to skip network connectivity check (default: false)
  ///
  /// Returns Either<Failure, T> with the result or appropriate failure
  static Future<Either<Failure, T>> handleOperation<T>({
    required Future<T> Function() operation,
    required NetworkInfo networkInfo,
    required String operationName,
    bool skipNetworkCheck = false,
  }) async {
    // Check network connectivity (unless skipped)
    if (!skipNetworkCheck && !await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No network connection'),
      );
    }

    try {
      final result = await operation();
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on PermissionException catch (e) {
      return Left(PermissionFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Unexpected error during $operationName: $e',
        ),
      );
    }
  }

  /// Execute a repository operation without network check
  ///
  /// Useful for local-only operations (e.g., database operations)
  ///
  /// [operation] - The async operation to execute
  /// [operationName] - Name of the operation (for error messages)
  ///
  /// Returns Either<Failure, T> with the result or appropriate failure
  static Future<Either<Failure, T>> handleLocalOperation<T>({
    required Future<T> Function() operation,
    required String operationName,
  }) async {
    return handleOperation<T>(
      operation: operation,
      networkInfo: _DummyNetworkInfo(),
      operationName: operationName,
      skipNetworkCheck: true,
    );
  }

  /// Convert an exception to a failure
  ///
  /// Useful when you need to convert exceptions outside of handleOperation
  ///
  /// [exception] - The exception to convert
  /// [defaultMessage] - Default message if exception doesn't have one
  ///
  /// Returns the appropriate Failure
  static Failure exceptionToFailure(
    dynamic exception, {
    String? defaultMessage,
  }) {
    if (exception is CacheException) {
      return CacheFailure(message: exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(message: exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is ServerException) {
      return ServerFailure(message: exception.message);
    } else if (exception is AuthException) {
      return AuthFailure(message: exception.message);
    } else if (exception is PermissionException) {
      return PermissionFailure(message: exception.message);
    } else {
      return ServerFailure(
        message: defaultMessage ?? exception.toString(),
      );
    }
  }
}

/// Dummy network info for local operations
/// Always returns true for connectivity check
class _DummyNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}
