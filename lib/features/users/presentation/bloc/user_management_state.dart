import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/user_entity.dart';

/// States for user management
abstract class UserManagementState extends BaseState {
  const UserManagementState();
}

/// Initial state
class UserManagementInitial extends UserManagementState {
  const UserManagementInitial();
}

/// Loading state
class UserManagementLoading extends UserManagementState {
  const UserManagementLoading();
}

/// Loaded state with users
class UserManagementLoaded extends UserManagementState {
  final List<UserEntity> users;

  const UserManagementLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

/// Error state
class UserManagementError extends UserManagementState {
  final String message;

  const UserManagementError(this.message);

  @override
  List<Object?> get props => [message];
}

