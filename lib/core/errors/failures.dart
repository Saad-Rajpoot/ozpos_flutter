import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;
  
  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}
