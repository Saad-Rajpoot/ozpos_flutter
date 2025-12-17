import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/repository_error_handler.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_data_source.dart';

/// Implementation of UserRepository
class UserRepositoryImpl implements UserRepository {
  final UserDataSource userDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.userDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers() async {
    return RepositoryErrorHandler.handleOperation<List<UserEntity>>(
      operation: () async => await userDataSource.getUsers(),
      networkInfo: networkInfo,
      operationName: 'loading users',
    );
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(String userId) async {
    return RepositoryErrorHandler.handleOperation<UserEntity>(
      operation: () async => await userDataSource.getUserById(userId),
      networkInfo: networkInfo,
      operationName: 'loading user',
    );
  }

  @override
  Future<Either<Failure, UserEntity>> createUser(UserEntity user) async {
    return RepositoryErrorHandler.handleOperation<UserEntity>(
      operation: () async => await userDataSource.createUser(user),
      networkInfo: networkInfo,
      operationName: 'creating user',
    );
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user) async {
    return RepositoryErrorHandler.handleOperation<UserEntity>(
      operation: () async => await userDataSource.updateUser(user),
      networkInfo: networkInfo,
      operationName: 'updating user',
    );
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    return RepositoryErrorHandler.handleOperation<void>(
      operation: () async => await userDataSource.deleteUser(userId),
      networkInfo: networkInfo,
      operationName: 'deleting user',
    );
  }
}

