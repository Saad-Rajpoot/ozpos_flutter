# JSON Code Generation Rules for OZPOS Flutter

## 📋 Table of Contents
1. [Overview](#overview)
2. [Project Structure](#project-structure)
3. [JSON Analysis](#json-analysis)
4. [Feature Organization](#feature-organization)
5. [Entity Creation](#entity-creation)
6. [Model Creation](#model-creation)
7. [Data Source Creation](#data-source-creation)
8. [Repository Creation](#repository-creation)
9. [Use Case Creation](#use-case-creation)
10. [BLoC Creation](#bloc-creation)
11. [Integration](#integration)
12. [Naming Conventions](#naming-conventions)
13. [File Organization](#file-organization)

---

## 🎯 Overview

This document defines the rules and guidelines for generating Flutter code from JSON responses in the OZPOS project. The project follows **Clean Architecture** principles with a structured approach to feature development.

**When to use these rules:**
- When you receive a JSON response from an API endpoint
- When creating new features that involve API data
- When organizing code for existing or new API endpoints

---

## 🏗️ Project Structure

The OZPOS Flutter project follows this structure:

```
lib/
├── core/                    # Shared utilities, base classes
│   ├── constants/          # App-wide constants
│   ├── di/                 # Dependency Injection setup
│   ├── errors/             # Error handling
│   ├── network/            # API Client & Network utilities
│   └── ...
└── features/               # Feature modules
    └── feature_name/
        ├── data/           # Data layer (API, DB, Models)
        │   ├── datasources/
        │   ├── models/
        │   └── repositories/
        ├── domain/         # Business logic layer
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        └── presentation/   # UI layer
            ├── bloc/
            ├── screens/
            └── widgets/
```

---

## 🔍 JSON Analysis

### Step 1: Analyze the JSON Structure
Before generating code, analyze the JSON response:

1. **Identify the root object structure**
   ```json
   {
     "data": [...],      // Array of items (most common)
     "message": "...",   // Success message
     "status": "success" // Status indicator
   }
   ```

2. **Identify nested objects and arrays**
   - Look for relationships between objects
   - Identify required vs optional fields
   - Note data types (string, int, double, bool, arrays, nested objects)

3. **Determine the feature name**
   - Use the API endpoint name (e.g., `/users` → `users` feature)
   - Use the main entity name from the JSON

---

## 📁 Feature Organization

### Step 2: Create or Update Feature Structure

**For new features:**
1. Create a new folder under `lib/features/` using snake_case
2. Create the standard subdirectories:
   ```
   features/
   └── new_feature/
       ├── data/
       │   ├── datasources/
       │   ├── models/
       │   └── repositories/
       ├── domain/
       │   ├── entities/
       │   ├── repositories/
       │   └── usecases/
       └── presentation/
           ├── bloc/
           ├── screens/
           └── widgets/
   ```

**For existing features:**
- Add new entities/models to existing folders
- Follow the same structure within the existing feature

---

## 🏭 Entity Creation

### Step 3: Create Domain Entities

**Location:** `lib/features/{feature_name}/domain/entities/`

**Rules:**
1. **File naming:** `{entity_name}_entity.dart`
2. **Class naming:** `{EntityName}Entity` (PascalCase)
3. **Always extend `Equatable`** for value equality
4. **Include all JSON fields as final properties**
5. **Handle nullable fields appropriately**
6. **Add computed properties if needed**

**Example:**
```dart
// user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, avatar, createdAt];
}
```

**For JSON with nested objects:**
- Create separate entity files for each nested object
- Use entity references in parent entities

---

## 📊 Model Creation

### Step 4: Create Data Models

**Location:** `lib/features/{feature_name}/data/models/`

**Rules:**
1. **File naming:** `{model_name}_model.dart`
2. **Class naming:** `{ModelName}Model` (PascalCase)
3. **Always include:**
   - Constructor with all fields
   - `fromJson()` factory method
   - `toJson()` method
   - `toEntity()` method to convert to domain entity
   - `fromEntity()` factory method
   - `copyWith()` method for immutability
   - Proper equality and hashCode overrides

**Example:**
```dart
// user_model.dart
import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.createdAt,
  });

  // Create entity from model
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      avatar: avatar,
      createdAt: createdAt,
    );
  }

  // Create model from entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatar: entity.avatar,
      createdAt: entity.createdAt,
    );
  }

  // JSON conversion methods
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Copy with method
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.avatar == avatar &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email, avatar, createdAt);
  }
}
```

---

## 🌐 Data Source Creation

### Step 5: Create Data Sources

**Location:** `lib/features/{feature_name}/data/datasources/`

**Rules:**
1. **Create three data source types:**
   - **Remote Data Source** (API calls) - **REQUIRED**
   - **Mock Data Source** (Local test data) - **REQUIRED**
   - **Local Data Source** (Database/Cache) - **REQUIRED**

2. **File naming pattern:**
   - `{feature_name}_remote_datasource.dart`
   - `{feature_name}_mock_datasource.dart`
   - `{feature_name}_local_datasource.dart`

3. **Interface naming:** `{FeatureName}RemoteDataSource`
4. **Implementation naming:** `{FeatureName}RemoteDataSourceImpl`

**Remote Data Source Example:**
```dart
// user_remote_datasource.dart
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUserById(String id);
  Future<UserModel> createUser(UserModel user);
  Future<UserModel> updateUser(String id, UserModel user);
  Future<void> deleteUser(String id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await apiClient.get('/users');
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getUserById(String id) async {
    try {
      final response = await apiClient.get('/users/$id');
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(data['data']);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ... other methods
}
```

**Mock Data Source Example:**
```dart
// user_mock_datasource.dart
import '../models/user_model.dart';

class UserMockDataSourceImpl implements UserRemoteDataSource {
  @override
  Future<List<UserModel>> getUsers() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      const UserModel(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        avatar: 'https://example.com/avatar1.jpg',
        createdAt: DateTime(2023, 1, 1),
      ),
      // ... more mock data
    ];
  }

  // ... other methods
}
```

---

## 🏪 Repository Creation

### Step 6: Create Repository Implementation

**Location:** `lib/features/{feature_name}/data/repositories/`

**Rules:**
1. **File naming:** `{feature_name}_repository_impl.dart`
2. **Class naming:** `{FeatureName}RepositoryImpl`
3. **Implement the domain repository interface**
4. **Handle network connectivity checks**
5. **Manage remote/local data source switching**
6. **Convert models to entities**

**Example:**
```dart
// user_repository_impl.dart
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../datasources/user_local_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource? localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
  });

  @override
  Future<List<UserEntity>> getUsers() async {
    try {
      final userModels = await remoteDataSource.getUsers();
      return userModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  // ... other methods
}
```

---

## 🎯 Use Case Creation

### Step 7: Create Use Cases

**Location:** `lib/features/{feature_name}/domain/usecases/`

**Rules:**
1. **File naming:** `get_{entity_name}s.dart`, `create_{entity_name}.dart`, etc.
2. **Class naming:** `Get{EntityName}s`, `Create{EntityName}`, etc.
3. **Each use case should have a single responsibility**
4. **Return Either<Failure, SuccessType>** for error handling

**Example:**
```dart
// get_users.dart
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUsers implements UseCase<List<UserEntity>, NoParams> {
  final UserRepository repository;

  GetUsers(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(NoParams params) async {
    try {
      final users = await repository.getUsers();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
```

---

## 🎮 BLoC Creation

### Step 8: Create BLoC State Management

**Location:** `lib/features/{feature_name}/presentation/bloc/`

**Rules:**
1. **File naming pattern:**
   - `{feature_name}_bloc.dart`
   - `{feature_name}_event.dart`
   - `{feature_name}_state.dart`

2. **Class naming:**
   - `{FeatureName}Bloc`
   - `{FeatureName}Event`
   - `{FeatureName}State`

3. **State should extend `Equatable`**
4. **Handle loading, success, and error states**

**Example:**
```dart
// user_bloc.dart
import '../../../../core/bloc/base_bloc.dart';
import '../../domain/usecases/get_users.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends BaseBloc<UserEvent, UserState> {
  final GetUsers getUsers;

  UserBloc({required this.getUsers}) : super(UserInitial()) {
    on<GetUserListEvent>(_onGetUsers);
  }

  Future<void> _onGetUsers(
    GetUserListEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    final result = await getUsers(NoParams());

    result.fold(
      (failure) => emit(UserError(message: failure.message)),
      (users) => emit(UserLoaded(users: users)),
    );
  }
}
```

---

## 🔗 Integration

### Step 9: Integrate with Dependency Injection

**Update:** `lib/core/di/injection_container.dart`

**Rules:**
1. **Add data source registration** (remote, local, mock)
2. **Add repository registration**
3. **Add use case registration**
4. **Add BLoC registration**
5. **Include environment-based switching logic**

**Example:**
```dart
// In injection_container.dart
Future<void> _initUser(GetIt sl) async {
  // Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(() {
    if (AppConfig.instance.useMockData) {
      return UserMockDataSourceImpl();
    } else {
      return UserRemoteDataSourceImpl(apiClient: sl());
    }
  });

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl.isRegistered<UserLocalDataSource>()
          ? sl<UserLocalDataSource>()
          : null,
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUsers(sl()));

  // BLoC
  sl.registerFactory(() => UserBloc(getUsers: sl()));
}
```

---

## 📝 Naming Conventions

### File Naming (snake_case)
- `user_entity.dart`
- `user_model.dart`
- `user_remote_datasource.dart`
- `user_repository_impl.dart`
- `get_users.dart`
- `user_bloc.dart`

### Class Naming (PascalCase)
- `UserEntity`
- `UserModel`
- `UserRemoteDataSource`
- `UserRepositoryImpl`
- `GetUsers`
- `UserBloc`

### Variable Naming (camelCase)
- `userEntity`
- `userModel`
- `apiClient`
- `createdAt`

### Constant Naming (SCREAMING_SNAKE_CASE)
- `GET_USERS_ENDPOINT`
- `USER_CACHE_KEY`

---

## 📂 File Organization Rules

### For Multiple Entities in One JSON Response
1. **Create separate entity files** for each distinct object type
2. **Group related entities** in the same feature folder
3. **Use composition** for nested relationships

### For Files That Don't Fit Existing Features
1. **Analyze the API endpoint** to determine the primary feature
2. **Create a new feature folder** if no suitable existing feature exists
3. **Use descriptive feature names** based on the API functionality

### For Cross-Feature Dependencies
1. **Create shared entities** in the `core/` folder if used across multiple features
2. **Reference existing entities** instead of duplicating them
3. **Maintain separation of concerns** between features

---

## ✅ Quality Assurance Checklist

Before completing the implementation:

- [ ] **All entities extend `Equatable`**
- [ ] **All models have `fromJson`/`toJson` methods**
- [ ] **All data sources implement proper error handling**
- [ ] **Repository methods return domain entities**
- [ ] **Use cases handle errors with `Either<Failure, Success>`**
- [ ] **BLoC states extend `Equatable`**
- [ ] **Dependencies are registered in `injection_container.dart`**
- [ ] **API endpoints are added to `app_constants.dart`**
- [ ] **File naming follows snake_case convention**
- [ ] **Class naming follows PascalCase convention**
- [ ] **Code passes linting checks**

---

## 🚀 Next Steps After Code Generation

1. **Add API endpoints** to `lib/core/constants/app_constants.dart`
2. **Register dependencies** in `injection_container.dart`
3. **Create UI screens** in `presentation/screens/`
4. **Add navigation routes** in `app_router.dart`
5. **Write unit tests** for use cases
6. **Write widget tests** for UI components
7. **Test error scenarios** thoroughly

This structured approach ensures consistency, maintainability, and scalability across the OZPOS Flutter application.
