# Addons Feature Architecture Guide

## Overview
This document outlines the complete architecture pattern used for implementing the **addons feature** in the OZPOS Flutter application. The addons feature allows creating reusable add-on categories (like cheese options, sauces, extra toppings) that can be attached to menu items.

## Architecture Pattern

### 🏗️ **Clean Architecture Structure**

The addons feature follows Clean Architecture principles with clear separation of concerns:

```
lib/features/addons/
├── domain/           # Business logic layer
│   ├── entities/     # Core business objects
│   ├── repositories/ # Abstract data contracts
│   └── usecases/     # Application-specific business rules
├── data/            # Data access layer
│   ├── datasources/  # Data sources (API, local DB, mock)
│   ├── models/       # Data transfer objects
│   └── repositories/ # Concrete data implementations
└── presentation/    # UI layer
    ├── bloc/        # State management (BLoC pattern)
    ├── screens/     # UI screens
    └── widgets/     # Reusable UI components
```

### 📁 **File Structure & Naming Convention**

**Domain Layer:**
- `entities/addon_management_entities.dart` - Pure business objects
- `repositories/addon_repository.dart` - Abstract data contracts
- `usecases/get_addon_categories.dart` - Business use cases

**Data Layer:**
- `datasources/addon_*.dart` - Data access implementations
- `models/addon_*_model.dart` - JSON serialization models
- `repositories/addon_repository_impl.dart` - Concrete implementations

**Presentation Layer:**
- `bloc/addon_management_*.dart` - BLoC state management
- `screens/addon_categories_screen.dart` - UI screens

## Implementation Patterns

### 1. **Entity Pattern** (`AddonCategory`, `AddonItem`)

```dart
// Immutable business objects with Equatable
class AddonCategory extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<AddonItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  // CopyWith method for immutability
  AddonCategory copyWith({...});

  @override
  List<Object?> get props => [id, name, description, items, createdAt, updatedAt];
}
```

**Key Principles:**
- ✅ Immutable objects using `const` constructors
- ✅ `Equatable` for value equality comparison
- ✅ `copyWith` method for immutable updates
- ✅ Simple, focused properties
- ✅ No business logic in entities

### 2. **BLoC State Management Pattern**

**Events** (`addon_management_event.dart`):
```dart
abstract class AddonManagementEvent extends Equatable {
  const AddonManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadAddonCategoriesEvent extends AddonManagementEvent {
  const LoadAddonCategoriesEvent();
}
```

**States** (`addon_management_state.dart`):
```dart
abstract class AddonManagementState extends Equatable {
  const AddonManagementState();

  @override
  List<Object?> get props => [];
}

class AddonManagementLoaded extends AddonManagementState {
  final List<AddonCategory> categories;

  const AddonManagementLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}
```

**BLoC** (`addon_management_bloc.dart`):
```dart
class AddonManagementBloc extends Bloc<AddonManagementEvent, AddonManagementState> {
  final GetAddonCategories _getAddonCategories;

  AddonManagementBloc({required GetAddonCategories getAddonCategories})
      : _getAddonCategories = getAddonCategories,
        super(const AddonManagementInitial()) {
    on<LoadAddonCategoriesEvent>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(LoadAddonCategoriesEvent event, Emitter emit) async {
    emit(const AddonManagementLoading());

    final result = await _getAddonCategories(const NoParams());

    result.fold(
      (failure) => emit(AddonManagementError('Failed to load categories: ${failure.message}')),
      (categories) => emit(AddonManagementLoaded(categories: categories)),
    );
  }
}
```

**Key Principles:**
- ✅ Single Responsibility: Each BLoC handles one feature
- ✅ Event-driven architecture
- ✅ Immutable state updates
- ✅ Error handling with dedicated error states
- ✅ Loading states for better UX

### 3. **Use Case Pattern** (Clean Architecture)

```dart
class GetAddonCategories implements UseCase<List<AddonCategory>, NoParams> {
  final AddonRepository repository;

  GetAddonCategories(this.repository);

  @override
  Future<Either<Failure, List<AddonCategory>>> call(NoParams params) async {
    return repository.getAddonCategories();
  }
}
```

**Key Principles:**
- ✅ Single responsibility: One use case per business action
- ✅ Dependency injection via constructor
- ✅ Functional approach using `Either` for error handling
- ✅ No direct data access - uses repository abstraction

### 4. **Repository Pattern**

**Abstract Repository** (`addon_repository.dart`):
```dart
abstract class AddonRepository {
  Future<Either<Failure, List<AddonCategory>>> getAddonCategories();
}
```

**Concrete Implementation** (`addon_repository_impl.dart`):
```dart
class AddonRepositoryImpl implements AddonRepository {
  final AddonDataSource addonDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<AddonCategory>>> getAddonCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await addonDataSource.getAddonCategories();
        return Right(categories);
      } on ServerException {
        return Left(ServerFailure(message: 'Server error'));
      }
    } else {
      return Left(NetworkFailure(message: 'Network error'));
    }
  }
}
```

**Key Principles:**
- ✅ Dependency Inversion: Depends on abstractions, not concretions
- ✅ Network awareness: Checks connectivity before API calls
- ✅ Proper error handling using custom exceptions and failures
- ✅ Single responsibility per repository

### 5. **Data Source Pattern**

**Mock Data Source** (`addon_mock_datasource.dart`):
```dart
class AddonMockDataSourceImpl implements AddonDataSource {
  @override
  Future<List<AddonCategory>> getAddonCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final jsonString = await rootBundle.loadString(
        'assets/addons_data/addon_categories.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((categoryData) {
        final categoryModel = AddonCategoryModel.fromJson(categoryData);
        return categoryModel.toEntity();
      }).toList();
    } catch (e) {
      // Fallback to error simulation
      throw Exception('Failed to load addon categories: $e');
    }
  }
}
```

**Local Data Source** (`addon_local_datasource.dart`):
```dart
class AddonLocalDataSourceImpl implements AddonDataSource {
  final Database database;

  @override
  Future<List<AddonCategory>> getAddonCategories() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query('addon_categories');
      return maps.map((json) => AddonCategoryModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch addon categories from local database');
    }
  }
}
```

**Key Principles:**
- ✅ Multiple data sources for different environments (mock, local, remote)
- ✅ Consistent interface via abstract `AddonDataSource`
- ✅ Proper error handling with custom exceptions
- ✅ JSON parsing with fallback mechanisms
- ✅ Network simulation for development

### 6. **Model Pattern** (Data Transfer Objects)

```dart
class AddonCategoryModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<AddonItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  // JSON serialization
  factory AddonCategoryModel.fromJson(Map<String, dynamic> json) {
    return AddonCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => AddonItemModel.fromJson(item))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Entity conversion
  AddonCategory toEntity() {
    return AddonCategory(
      id: id,
      name: name,
      description: description,
      items: items.map((item) => item.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
```

**Key Principles:**
- ✅ JSON serialization/deserialization
- ✅ Entity conversion methods (`toEntity()`, `fromEntity()`)
- ✅ Proper null handling in JSON parsing
- ✅ DateTime parsing from ISO strings

### 7. **UI Screen Pattern**

**State Management Integration**:
```dart
BlocBuilder<AddonManagementBloc, AddonManagementState>(
  builder: (context, state) {
    if (state is AddonManagementLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AddonManagementError) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            Text('Error: ${state.message}'),
            ElevatedButton(
              onPressed: () => context.read<AddonManagementBloc>().add(
                const LoadAddonCategoriesEvent(),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is AddonManagementLoaded) {
      return _buildCategoryList(context, state);
    }

    return const SizedBox.shrink();
  },
)
```

**Key Principles:**
- ✅ Comprehensive state handling (loading, error, loaded, empty)
- ✅ Error recovery with retry functionality
- ✅ Proper loading indicators
- ✅ Empty state handling

## JSON Data Structure

```json
[
  {
    "id": "cheese-options",
    "name": "Cheese Options",
    "description": "Choose your cheese",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z",
    "items": [
      {
        "id": "cheese-cheddar",
        "name": "Cheddar Cheese",
        "basePriceDelta": 1.50
      }
    ]
  }
]
```

**Key Principles:**
- ✅ Consistent ID naming (kebab-case)
- ✅ ISO 8601 datetime format
- ✅ Clear hierarchy (categories contain items)
- ✅ Price deltas for add-on pricing

## Dependency Injection Setup

```dart
// Register data sources
sl.registerLazySingleton<AddonDataSource>(
  () => AddonMockDataSourceImpl(),
);

// Register repositories
sl.registerLazySingleton<AddonRepository>(
  () => AddonRepositoryImpl(
    addonDataSource: sl(),
    networkInfo: sl(),
  ),
);

// Register use cases
sl.registerLazySingleton(
  () => GetAddonCategories(sl()),
);

// Register BLoC
sl.registerFactory(
  () => AddonManagementBloc(
    getAddonCategories: sl(),
  ),
);
```

## Asset Structure

```
assets/addons_data/
├── addon_categories.json       # Success data
└── addon_categories_error.json # Error simulation data
```

## Error Handling Strategy

1. **Data Layer**: Custom exceptions (`ServerException`, `CacheException`)
2. **Domain Layer**: Either monad with `Failure` types
3. **Presentation Layer**: Dedicated error states with user-friendly messages
4. **Recovery**: Retry mechanisms and fallback data sources

## Testing Strategy

Each layer should have corresponding tests:
- **Entities**: Equatable behavior, copyWith functionality
- **Use Cases**: Repository interaction, error handling
- **Repositories**: Data source integration, network handling
- **BLoC**: State transitions, event handling
- **Data Sources**: JSON parsing, error simulation

## Key Benefits of This Architecture

1. **🔄 Reusability**: Addon categories can be reused across menu items
2. **🧪 Testability**: Each layer can be tested in isolation
3. **🔧 Maintainability**: Clear separation of concerns
4. **📈 Scalability**: Easy to add new features or data sources
5. **🔒 Type Safety**: Strong typing throughout the application
6. **🚀 Performance**: Efficient state management and data loading

## Usage Guidelines

When implementing similar features:

1. **Always follow the Clean Architecture pattern**
2. **Use BLoC for state management in presentation layer**
3. **Implement proper error handling at every layer**
4. **Create comprehensive JSON structures with fallbacks**
5. **Use dependency injection for better testability**
6. **Follow consistent naming conventions**
7. **Implement loading and error states in UI**

This pattern can be applied to any feature that requires:
- Data fetching from multiple sources
- Complex state management
- Offline support
- Error recovery
- Reusable business entities
