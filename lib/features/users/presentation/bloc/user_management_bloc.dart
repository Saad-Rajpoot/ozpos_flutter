import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import 'user_management_event.dart';
import 'user_management_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_users.dart';
import '../../domain/usecases/create_user.dart';
import '../../domain/usecases/update_user.dart';

class UserManagementBloc
    extends BaseBloc<UserManagementEvent, UserManagementState> {
  final GetUsers _getUsers;
  final CreateUser _createUser;
  final UpdateUser _updateUser;

  UserManagementBloc({
    required GetUsers getUsers,
    required CreateUser createUser,
    required UpdateUser updateUser,
  }) : _getUsers = getUsers,
       _createUser = createUser,
       _updateUser = updateUser,
       super(const UserManagementInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UserManagementState> emit,
  ) async {
    emit(const UserManagementLoading());

    final result = await _getUsers(const NoParams());

    result.fold(
      (failure) => emit(
        UserManagementError('Failed to load users: ${failure.message}'),
      ),
      (users) => emit(UserManagementLoaded(users: users)),
    );
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<UserManagementState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserManagementLoaded) {
      emit(const UserManagementLoading());
    }

    final result = await _createUser(event.user);

    result.fold(
      (failure) {
        emit(UserManagementError('Failed to create user: ${failure.message}'));
        if (currentState is UserManagementLoaded) {
          emit(currentState);
        }
      },
      (createdUser) {
        if (currentState is UserManagementLoaded) {
          final updatedUsers = List<UserEntity>.from(currentState.users)
            ..add(createdUser);
          emit(UserManagementLoaded(users: updatedUsers));
        } else {
          emit(UserManagementLoaded(users: [createdUser]));
        }
      },
    );
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UserManagementState> emit,
  ) async {
    final currentState = state;
    if (currentState is UserManagementLoaded) {
      emit(const UserManagementLoading());
    }

    final result = await _updateUser(event.user);

    result.fold(
      (failure) {
        emit(UserManagementError('Failed to update user: ${failure.message}'));
        if (currentState is UserManagementLoaded) {
          emit(currentState);
        }
      },
      (updatedUser) {
        if (currentState is UserManagementLoaded) {
          // Replace the updated user in the list
          final updatedUsers = currentState.users.map((user) {
            return user.id == updatedUser.id ? updatedUser : user;
          }).toList();
          emit(UserManagementLoaded(users: updatedUsers));
        } else {
          emit(UserManagementLoaded(users: [updatedUser]));
        }
      },
    );
  }
}

