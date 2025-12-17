import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/user_entity.dart';

/// Events for user management
abstract class UserManagementEvent extends BaseEvent {
  const UserManagementEvent();
}

/// Load all users
class LoadUsersEvent extends UserManagementEvent {
  const LoadUsersEvent();
}

/// Create a new user
class CreateUserEvent extends UserManagementEvent {
  final UserEntity user;

  const CreateUserEvent({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Update an existing user
class UpdateUserEvent extends UserManagementEvent {
  final UserEntity user;

  const UpdateUserEvent({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Delete a user
class DeleteUserEvent extends UserManagementEvent {
  final String userId;

  const DeleteUserEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

