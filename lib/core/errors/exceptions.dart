/// Base class for all exceptions
abstract class AppException implements Exception {
  final String message;
  
  const AppException({required this.message});
}

/// Server exception
class ServerException extends AppException {
  const ServerException({required super.message});
}

/// Cache exception
class CacheException extends AppException {
  const CacheException({required super.message});
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException({required super.message});
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException({required super.message});
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException({required super.message});
}

/// Permission exception
class PermissionException extends AppException {
  const PermissionException({required super.message});
}
