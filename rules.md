# OZPOS Development Rules & Guidelines

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Feature Development Checklist](#feature-development-checklist)
3. [Clean Architecture Layers](#clean-architecture-layers)
4. [Naming Conventions](#naming-conventions)
5. [State Management](#state-management)
6. [Dependency Injection](#dependency-injection)
7. [Error Handling](#error-handling)
8. [Code Quality](#code-quality)
9. [Security Best Practices](#security-best-practices)
10. [Testing Guidelines](#testing-guidelines)

---

## 🏗️ Architecture Overview

This project follows **Clean Architecture** principles with three main layers:

```
lib/
├── core/                    # Shared utilities, base classes
│   ├── base/               # Base classes (BLoC, Repository, UseCase)
│   ├── constants/          # App-wide constants
│   ├── di/                 # Dependency Injection setup
│   ├── errors/             # Error handling (Failures, Exceptions)
│   ├── navigation/         # Routing & Navigation
│   ├── network/            # API Client & Network utilities
│   ├── theme/              # Theme configuration
│   ├── utils/              # Helper functions
│   └── widgets/            # Reusable widgets
│
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

## ✅ Feature Development Checklist

### When creating a new feature, follow these steps:

#### 1️⃣ **Domain Layer** (Business Logic) - Start Here
- [ ] Create entities in `domain/entities/`
- [ ] Define repository interfaces in `domain/repositories/`
- [ ] Implement use cases in `domain/usecases/`

#### 2️⃣ **Data Layer** (Implementation)
- [ ] Create request models in `data/models/` (with `toJson` for API requests)
- [ ] Create response models in `data/models/` (with `fromJson`, `toJson`)
- [ ] Implement data sources in `data/datasources/` ⚠️ **MANDATORY**
  - **Remote data source** (API calls using request models) - **REQUIRED**
  - **Mock data source** (Local mock data) - **REQUIRED** ⭐
  - **Local data source** (Cache/DB if needed) - Optional
- [ ] Implement repositories in `data/repositories/`
- [ ] Add switch flag in `injection_container.dart` for mock/remote toggle ⚠️

#### 3️⃣ **Presentation Layer** (UI)
- [ ] Create BLoC files in `presentation/bloc/`:
  - `feature_bloc.dart`
  - `feature_event.dart`
  - `feature_state.dart`
- [ ] Create screens in `presentation/screens/`
- [ ] Create feature-specific widgets in `presentation/widgets/`

#### 4️⃣ **Integration**
- [ ] Register dependencies in `core/di/injection_container.dart`
- [ ] Add routes in `core/navigation/app_router.dart`
- [ ] Add BlocProvider in `main.dart` MultiBlocProvider (if needed globally)
- [ ] Add API endpoints in `core/constants/app_constants.dart`
- [ ] Update constants if needed

#### 5️⃣ **Quality Assurance**
- [ ] Write unit tests for use cases
- [ ] Write widget tests for UI
- [ ] Check for linter errors
- [ ] Test error scenarios
- [ ] Verify navigation flow

---

## 🎯 Clean Architecture Layers

### **Domain Layer** (Business Logic - Independent)
**Purpose:** Core business logic, completely independent of external frameworks

**Rules:**
- ✅ NO dependencies on other layers
- ✅ Contains only business entities and rules
- ✅ Pure Dart code (no Flutter imports)
- ✅ Use cases should be single-responsibility

**Example Entity:**
```dart
// domain/entities/product_entity.dart
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final double price;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, price];
}
```

**Example Repository Interface:**
```dart
// domain/repositories/product_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();
  Future<Either<Failure, ProductEntity>> getProductById(String id);
}
```

**Example Use Case:**
```dart
// domain/usecases/get_products.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/base/base_usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProducts implements UseCase<List<ProductEntity>, NoParams> {
  final ProductRepository repository;

  GetProducts({required this.repository});

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) async {
    return await repository.getProducts();
  }
}
```

---

### **Data Layer** (Implementation)
**Purpose:** Handles data from various sources (API, Database, Cache, Mock)

**Rules:**
- ✅ Implements domain repository interfaces
- ✅ Response models should extend domain entities
- ✅ Request models are standalone (don't extend entities)
- ✅ Handle data transformations (JSON ↔ Objects)
- ✅ Always use request models for API calls (no hardcoded maps)
- ✅ Throw exceptions, let repository convert to Failures
- ✅ **MANDATORY:** Every feature MUST have both Remote and Mock data sources
- ✅ Add local data source only if caching/persistence is needed

**Data Source Types:**
1. **Remote Data Source** - API calls (REQUIRED for every feature)
2. **Mock Data Source** - Test data (REQUIRED for every feature) ⭐
3. **Local Data Source** - Cache/Database (Optional, only if needed)

**Model Types:**
1. **Request Models**: For sending data to API (only `toJson()`)
2. **Response Models**: For receiving data from API (extends entity, has `fromJson()` and `toJson()`)

**Example Response Model:**
```dart
// data/models/product_model.dart
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}
```

**Example Request Model:**
```dart
// data/models/create_product_request_model.dart
class CreateProductRequestModel {
  final String name;
  final double price;
  final String? description;

  const CreateProductRequestModel({
    required this.name,
    required this.price,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      if (description != null) 'description': description,
    };
  }
}
```

**Example Data Source:**
```dart
// data/datasources/product_remote_datasource.dart
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/product_model.dart';
import '../models/create_product_request_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> createProduct(CreateProductRequestModel request);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await apiClient.get(AppConstants.getProductsEndpoint);
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ProductModel> createProduct(CreateProductRequestModel request) async {
    try {
      final response = await apiClient.post(
        AppConstants.createProductEndpoint,
        data: request.toJson(),  // ✅ Using request model
      );
      final data = response.data as Map<String, dynamic>;
      return ProductModel.fromJson(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
```

**Example Repository Implementation:**
```dart
// data/repositories/product_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    // Implementation
    throw UnimplementedError();
  }
}
```

---

### **Data Sources - Complete Guide**

**⚠️ IMPORTANT:** Every feature MUST have:
1. ✅ Remote Data Source (API calls)
2. ✅ Mock Data Source (Test data) - **MANDATORY**
3. ✅ Local Data Source (Optional - only for caching)

---

#### **1. Remote Data Source (REQUIRED)**

**Purpose:** Makes actual API calls to backend

```dart
// data/datasources/product_remote_datasource.dart
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await apiClient.get(AppConstants.getProductsEndpoint);
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
```

---

#### **2. Mock Data Source (MANDATORY)** ⭐

**Purpose:** Provides test data for development without backend

**Why Mandatory?**
- ✅ Fast development without waiting for backend
- ✅ Offline testing
- ✅ Consistent data for UI development
- ✅ Demo without backend dependencies
- ✅ Easy to add/modify test scenarios

```dart
// data/datasources/product_local_datasource.dart
import '../models/product_model.dart';
import 'product_remote_datasource.dart';

/// Mock data source - MANDATORY for every feature
/// Implements same interface as remote data source
class ProductLocalDataSourceImpl implements ProductRemoteDataSource {
  @override
  Future<List<ProductModel>> getProducts() async {
    // Simulate network delay for realistic testing
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock data
    return [
      const ProductModel(
        id: '1',
        name: 'Burger',
        price: 5.99,
      ),
      const ProductModel(
        id: '2',
        name: 'Pizza',
        price: 12.99,
      ),
      const ProductModel(
        id: '3',
        name: 'Pasta',
        price: 8.99,
      ),
    ];
  }
}
```

**Mock Data Best Practices:**
- ✅ Include realistic data that matches your API structure
- ✅ Cover different scenarios (success, empty, edge cases)
- ✅ Add network delay simulation (300-500ms) for realistic feel
- ✅ Keep data updated when API structure changes
- ✅ Include enough variety for proper UI testing

---

#### **3. Local Data Source (Optional)**

**Purpose:** Cache data locally using SharedPreferences/Hive/SQLite

**Only create if you need:**
- Offline mode
- Data persistence
- Caching for performance

```dart
// data/datasources/product_local_cache_datasource.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

abstract class ProductLocalCacheDataSource {
  Future<List<ProductModel>> getCachedProducts();
  Future<void> cacheProducts(List<ProductModel> products);
}

class ProductLocalCacheDataSourceImpl implements ProductLocalCacheDataSource {
  final SharedPreferences sharedPreferences;

  ProductLocalCacheDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    final jsonString = sharedPreferences.getString('cached_products');
    if (jsonString != null) {
      // Parse and return cached data
      // Implementation details...
    }
    throw CacheException('No cached data');
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    // Save to cache
    // Implementation details...
  }
}
```

---

### **Environment-Based Configuration (PRODUCTION GRADE)**

**⚠️ IMPORTANT:** For production-level apps, use **environment-based configuration** instead of simple boolean flags.

#### Professional Approach:

**1. Create App Config (Singleton):**
```dart
// lib/core/config/app_config.dart
class AppConfig {
  static final AppConfig _instance = AppConfig._();
  static AppConfig get instance => _instance;
  
  AppEnvironment _environment = AppEnvironment.development;
  
  void initialize({required AppEnvironment environment}) {
    _environment = environment;
  }
  
  bool get useMockData {
    switch (_environment) {
      case AppEnvironment.development:
        return true;  // Mock data
      case AppEnvironment.staging:
      case AppEnvironment.production:
        return false; // Real API
    }
  }
  
  String get baseUrl {
    switch (_environment) {
      case AppEnvironment.development:
        return 'https://dev-api.ozpos.com';
      case AppEnvironment.staging:
        return 'https://staging-api.ozpos.com';
      case AppEnvironment.production:
        return 'https://api.ozpos.com';
    }
  }
}

enum AppEnvironment { development, staging, production }
```

**2. In main.dart:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment FIRST
  AppConfig.instance.initialize(
    environment: AppEnvironment.development, // Change as needed
  );
  
  await di.init();
  runApp(const MyApp());
}
```

**3. In Dependency Injection:**
```dart
Future<void> _initProduct(GetIt sl) async {
  // Automatic switching based on environment
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => AppConfig.instance.useMockData
        ? ProductMockDataSourceImpl() // Auto for dev
        : ProductRemoteDataSourceImpl(apiClient: sl()), // Auto for prod
  );

  // Rest of the setup...
}
```

**4. Create Separate Entry Points (RECOMMENDED):**
```dart
// lib/main_dev.dart - Development
void main() async {
  AppConfig.instance.initialize(environment: AppEnvironment.development);
  // ...
}

// lib/main_prod.dart - Production
void main() async {
  AppConfig.instance.initialize(environment: AppEnvironment.production);
  // ...
}
```

**Run commands:**
```bash
# Development
flutter run -t lib/main_dev.dart

# Production
flutter build apk -t lib/main_prod.dart --release
```

**Benefits:**
- ✅ **Production Safe**: Can't accidentally ship wrong config
- ✅ **Scalable**: Supports dev/staging/production
- ✅ **CI/CD Ready**: Automated builds without code changes
- ✅ **Industry Standard**: Used by all major companies
- ✅ **Environment-specific URLs**: Different APIs per environment
- ✅ **Professional**: Senior-level approach

**See `ENVIRONMENT_CONFIG.md` for complete guide.**

---

### **Presentation Layer** (UI)
**Purpose:** User interface and state management

**Rules:**
- ✅ Use BLoC for state management
- ✅ Extend base classes (BaseBloc, BaseState, BaseEvent)
- ✅ Keep UI logic minimal in widgets
- ✅ Use BlocBuilder, BlocListener appropriately

**Example BLoC Event:**
```dart
// presentation/bloc/product_event.dart
import '../../../../core/base/base_bloc.dart';

abstract class ProductEvent extends BaseEvent {
  const ProductEvent();
}

class LoadProducts extends ProductEvent {
  @override
  List<Object?> get props => [];
}

class LoadProductById extends ProductEvent {
  final String productId;

  const LoadProductById({required this.productId});

  @override
  List<Object?> get props => [productId];
}
```

**Example BLoC State:**
```dart
// presentation/bloc/product_state.dart
import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/product_entity.dart';

abstract class ProductState extends BaseState {
  const ProductState();
}

class ProductInitial extends ProductState {
  @override
  List<Object?> get props => [];
}

class ProductLoading extends ProductState {
  @override
  List<Object?> get props => [];
}

class ProductLoaded extends ProductState {
  final List<ProductEntity> products;

  const ProductLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ProductError extends ProductState {
  final String message;

  const ProductError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

**Example BLoC:**
```dart
// presentation/bloc/product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/base/base_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import '../../domain/usecases/get_products.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends BaseBloc<ProductEvent, ProductState> {
  final GetProducts getProducts;

  ProductBloc({required this.getProducts}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await getProducts(NoParams());

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(ProductLoaded(products: products)),
    );
  }
}
```

---

## 📝 Naming Conventions

### Files
- **Snake_case:** `product_screen.dart`, `user_repository.dart`
- **Descriptive names:** Include feature and type (e.g., `product_remote_datasource.dart`)

### Classes
- **PascalCase:** `ProductScreen`, `UserRepository`
- **Suffixes:**
  - Screens: `ProductScreen`, `LoginScreen`
  - Widgets: `ProductCard`, `CustomButton`
  - BLoCs: `ProductBloc`
  - Events: `LoadProducts`, `UpdateProduct`
  - States: `ProductLoaded`, `ProductError`
  - Repositories: `ProductRepository`
  - Data Sources: `ProductRemoteDataSource`
  - Models: `ProductModel`
  - Entities: `ProductEntity`
  - Use Cases: `GetProducts`, `UpdateProduct`

### Variables & Functions
- **camelCase:** `productList`, `getUserData()`
- **Descriptive:** Avoid single letters except for loops

### Constants
- **camelCase** (for class properties): `static const baseUrl = '...'`
- **SCREAMING_SNAKE_CASE** (for standalone): `const MAX_RETRY_COUNT = 3;`

---

## 🔄 State Management

### BLoC Pattern Rules

1. **Events should be nouns describing user actions:**
   ```dart
   LoadProducts()
   UpdateProduct()
   DeleteProduct()
   ```

2. **States should describe UI states:**
   ```dart
   ProductInitial()
   ProductLoading()
   ProductLoaded()
   ProductError()
   ```

3. **Always extend base classes:**
   ```dart
   class ProductBloc extends BaseBloc<ProductEvent, ProductState>
   class ProductEvent extends BaseEvent
   class ProductState extends BaseState
   ```

4. **Use Equatable for comparison:**
   ```dart
   @override
   List<Object?> get props => [id, name, price];
   ```

5. **Handle loading and error states:**
   ```dart
   BlocBuilder<ProductBloc, ProductState>(
     builder: (context, state) {
       if (state is ProductLoading) {
         return CircularProgressIndicator();
       } else if (state is ProductError) {
         return Text(state.message);
       } else if (state is ProductLoaded) {
         return ListView(...);
       }
       return SizedBox.shrink();
     },
   )
   ```

---

## 💉 Dependency Injection

### Registration in `injection_container.dart`

**Follow this pattern:**
```dart
Future<void> _initProduct(GetIt sl) async {
  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProducts(repository: sl()));
  sl.registerLazySingleton(() => GetProductById(repository: sl()));

  // BLoC (Factory - new instance each time)
  sl.registerFactory(() => ProductBloc(
    getProducts: sl(),
    getProductById: sl(),
  ));
}
```

**Then call in main `init()` function:**
```dart
Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => NavigationService());

  // Features
  await _initDashboard(sl);
  await _initProduct(sl);  // Add new feature
}
```

**Rules:**
- ✅ Use `registerLazySingleton` for repositories, data sources, use cases
- ✅ Use `registerFactory` for BLoCs (new instance needed)
- ✅ Use `registerSingleton` for instances that are already created
- ✅ Always use constructor injection (not service locator pattern in classes)

---

## ⚠️ Error Handling

### Exception vs Failure

**Exceptions** (Data Layer):
```dart
class ServerException implements Exception {
  final String message;
  ServerException({required this.message});
}

class CacheException implements Exception {
  final String message;
  CacheException({required this.message});
}
```

**Failures** (Domain Layer):
```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}
```

**Flow:**
1. Data sources throw **Exceptions**
2. Repository catches exceptions and returns **Failures** via `Either<Failure, Data>`
3. Use cases return `Either<Failure, Data>`
4. BLoC handles both success and failure cases

**Example:**
```dart
// In repository
try {
  final data = await remoteDataSource.getData();
  return Right(data);
} on ServerException catch (e) {
  return Left(ServerFailure(message: e.message));
} catch (e) {
  return Left(ServerFailure(message: 'Unexpected error'));
}

// In BLoC
result.fold(
  (failure) => emit(ErrorState(message: failure.message)),
  (data) => emit(LoadedState(data: data)),
);
```

---

## 🔒 Security Best Practices

### 1. Token Storage
**IMPORTANT:** Always use the key name **`'token'`** for storing authentication tokens [[memory:7173260]]

```dart
// Storing token
await sharedPreferences.setString('token', authToken);

// Retrieving token
final token = sharedPreferences.getString('token');

// DO NOT use variations like 'auth_token', 'user_token', etc.
```

### 2. API Security
```dart
// Always send token in headers
final token = sharedPreferences.getString('token');
if (token != null) {
  headers['Authorization'] = 'Bearer $token';
}
```

### 3. Sensitive Data
- ❌ Never hardcode API keys in code
- ✅ Use environment variables
- ❌ Never commit `.env` files
- ✅ Store sensitive data in SharedPreferences (encrypted if needed)

### 4. Error Messages
```dart
// ❌ DON'T expose sensitive info
return Left(ServerFailure(message: 'SQL Error: SELECT * FROM users WHERE...'));

// ✅ DO return generic messages
return Left(ServerFailure(message: 'Failed to fetch data'));
```

---

## 📊 Code Quality

### 1. Linting
```bash
# Check for linter errors
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### 2. Code Organization
```dart
// Order in class:
// 1. Static fields
// 2. Instance fields
// 3. Constructors
// 4. Override methods
// 5. Public methods
// 6. Private methods

class ProductScreen extends StatelessWidget {
  static const routeName = '/product';  // Static field
  
  final String productId;  // Instance field
  
  const ProductScreen({required this.productId});  // Constructor
  
  @override  // Override method
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {  // Private method
    // ...
  }
}
```

### 3. Comments
```dart
// Use comments for complex logic only
// Self-documenting code is better than excessive comments

// ❌ BAD: Obvious comment
// Get user name
final name = user.name;

// ✅ GOOD: Explains WHY, not WHAT
// Using cached data to avoid API rate limits
final products = await cacheDataSource.getProducts();
```

### 4. Code Formatting
```bash
# Auto-format code
dart format .
```

---

## 🧪 Testing Guidelines

### Unit Tests (Use Cases)
```dart
// test/features/product/domain/usecases/get_products_test.dart
void main() {
  late GetProducts useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProducts(repository: mockRepository);
  });

  test('should get products from repository', () async {
    // Arrange
    final products = [ProductEntity(id: '1', name: 'Test', price: 100)];
    when(mockRepository.getProducts())
        .thenAnswer((_) async => Right(products));

    // Act
    final result = await useCase(NoParams());

    // Assert
    expect(result, Right(products));
    verify(mockRepository.getProducts());
    verifyNoMoreInteractions(mockRepository);
  });
}
```

### Widget Tests
```dart
// test/features/product/presentation/screens/product_screen_test.dart
void main() {
  testWidgets('should show loading indicator when loading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductBloc>(
          create: (_) => mockProductBloc,
          child: ProductScreen(),
        ),
      ),
    );

    when(mockProductBloc.state).thenReturn(ProductLoading());

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

---

## 🚀 Navigation

### Add routes in `app_router.dart`

**⚠️ IMPORTANT:** All route names must be defined in `AppRouter` class ONLY. Never define route names in screen classes.

```dart
// ✅ CORRECT - Routes in AppRouter
class AppRouter {
  static const String dashboard = '/';
  static const String products = '/products';
  static const String productDetail = '/product-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      
      case products:
        return MaterialPageRoute(builder: (_) => const ProductScreen());
      
      case productDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: args['id']),
        );
      
      default:
        return MaterialPageRoute(builder: (_) => const ErrorScreen());
    }
  }
}

// ❌ WRONG - Don't define routes in screen classes
class LoginScreen extends StatelessWidget {
  static const String routeName = '/login'; // ❌ Don't do this
  ...
}
```

### Navigate
```dart
// Simple navigation
Navigator.pushNamed(context, AppRouter.products);

// With arguments
Navigator.pushNamed(
  context,
  AppRouter.productDetail,
  arguments: {'id': productId},
);

// Using NavigationService (for navigation outside widget tree)
sl<NavigationService>().navigateTo(AppRouter.products);
```

---

## 📦 Adding Dependencies

1. Add to `pubspec.yaml`
2. Run `flutter pub get`
3. If needed, register in dependency injection

```yaml
dependencies:
  # New dependency
  awesome_package: ^1.0.0
```

---

## 🔑 Critical Best Practices

### 1. **MultiBlocProvider Registration**
Always register feature BLoCs in `main.dart` MultiBlocProvider:

```dart
// main.dart
return MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
    BlocProvider<DashboardBloc>(create: (_) => di.sl<DashboardBloc>()),
    BlocProvider<ProductBloc>(create: (_) => di.sl<ProductBloc>()),
  ],
  child: MaterialApp(...),
);
```

**Why?** This makes BLoCs available throughout the app without creating multiple instances.

### 2. **API Endpoints in Constants**
Always define endpoints in `app_constants.dart`:

```dart
// ❌ DON'T - Hardcoded endpoint
final response = await apiClient.post('/auth/login', data: data);

// ✅ DO - Use constant
final response = await apiClient.post(AppConstants.loginEndpoint, data: data);
```

### 3. **Return Models from Data Sources**
Data sources should return models, not maps:

```dart
// ❌ DON'T - Return Map
abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login();
}

// ✅ DO - Return Model or Response class
abstract class AuthRemoteDataSource {
  Future<AuthResponse> login();
}

class AuthResponse {
  final UserModel user;
  final String token;
  AuthResponse({required this.user, required this.token});
}
```

### 3b. **Always Use Request Models for API Calls**
Never send hardcoded maps in API requests. Always create request models:

```dart
// ❌ DON'T - Hardcoded map
final response = await apiClient.post(
  AppConstants.loginEndpoint,
  data: {'email': email, 'password': password},
);

// ✅ DO - Use Request Model
final requestModel = LoginRequestModel(
  email: email,
  password: password,
);

final response = await apiClient.post(
  AppConstants.loginEndpoint,
  data: requestModel.toJson(),
);
```

**Request Model Example:**
```dart
class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
```

**Why?**
- **Type Safety**: Compiler catches errors at compile-time
- **Reusability**: Same model can be used in multiple places
- **Maintainability**: Easy to update fields in one place
- **Documentation**: Model serves as API contract documentation
- **Validation**: Can add validation logic in model
- **Testing**: Easier to mock and test with models

### 4. **Mock Data Sources (MANDATORY) with Environment Config**
Every feature MUST have mock data with **professional environment-based switching**:

```dart
// ❌ DON'T - Only remote data source
Future<void> _initProduct(GetIt sl) async {
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiClient: sl()),
  );
}

// ⚠️ OKAY for small projects but NOT RECOMMENDED for production
const bool _useMockData = true;
Future<void> _initProduct(GetIt sl) async {
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => _useMockData
        ? ProductMockDataSourceImpl()
        : ProductRemoteDataSourceImpl(apiClient: sl()),
  );
}

// ✅ DO - Environment-based (PRODUCTION GRADE)
Future<void> _initProduct(GetIt sl) async {
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => AppConfig.instance.useMockData
        ? ProductMockDataSourceImpl() // Auto-selected for dev
        : ProductRemoteDataSourceImpl(apiClient: sl()), // Auto for prod
  );
}
```

**Why Environment-Based Config?**
- **Production Safe**: Can't ship wrong configuration
- **Scalable**: Supports multiple environments (dev/staging/prod)
- **Professional**: Industry standard approach
- **CI/CD Ready**: Automated deployments
- **No Manual Changes**: Different builds automatically use correct config
- **Enterprise Level**: Used by Fortune 500 companies

**See `ENVIRONMENT_CONFIG.md` for complete guide.**

### 5. **Access response.data from ApiClient**
ApiClient returns `Response`, access data via `.data`:

```dart
// ✅ Correct way
final response = await apiClient.post(AppConstants.loginEndpoint, data: data);
final data = response.data as Map<String, dynamic>;
final user = UserModel.fromJson(data['user']);
```

### 6. **Route Names in AppRouter Only**
Never define route names in screen classes:

```dart
// ❌ DON'T - Route in screen class
class LoginScreen extends StatelessWidget {
  static const String routeName = '/login'; // Wrong!
  ...
}

// ✅ DO - Route in AppRouter
class AppRouter {
  static const String login = '/login';
  static const String dashboard = '/';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      ...
    }
  }
}

// ✅ Screen class without route name
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  ...
}
```

**Why?** 
- **Centralized Management**: All routes in one place
- **Easy Refactoring**: Change route names without searching through screen files
- **No Duplication**: Single source of truth for navigation
- **Better Testing**: Easy to mock routes for unit tests
- **Cleaner Screens**: Screen classes focus on UI, not routing config

**Benefits:**
```dart
// When you need to change a route, update only AppRouter
// Before: Search through 10+ screen files
// After: Update one line in AppRouter

// Example: Renaming route
class AppRouter {
  static const String login = '/auth/login'; // Changed from '/login'
}
// All Navigator.pushNamed(context, AppRouter.login) still work!
```

---

## 🎯 Complete Integration Checklist

When adding a new feature, follow this complete checklist:

### **Before Starting:**
- [ ] Review existing similar features
- [ ] Read relevant sections in rules.md
- [ ] Plan your architecture (Domain → Data → Presentation)

### **During Development:**

#### 1️⃣ Domain Layer
- [ ] Create entities (pure Dart, Equatable)
- [ ] Define repository interfaces
- [ ] Implement use cases (one responsibility each)

#### 2️⃣ Data Layer
- [ ] Create request models (with `toJson()`) for API calls ⚠️
- [ ] Create response models extending entities (with `fromJson()`, `toJson()`)
- [ ] Add API endpoints to `AppConstants` ⚠️
- [ ] Implement **remote data source** (API calls with request models) ⚠️ **REQUIRED**
- [ ] Implement **mock data source** (test data) ⚠️ **MANDATORY** ⭐
- [ ] Implement local cache data source (only if caching needed) - Optional
- [ ] Implement repository (convert exceptions to failures)
- [ ] Add **mock/remote switch flag** in `injection_container.dart` ⚠️

#### 3️⃣ Presentation Layer
- [ ] Create events (user actions)
- [ ] Create states (UI states)
- [ ] Implement BLoC (handle events, emit states)
- [ ] Create screens (UI only, no business logic)
- [ ] Create widgets (reusable components)

#### 4️⃣ Integration
- [ ] Add API endpoints to `AppConstants` ⚠️
- [ ] Add routes to `AppRouter` (NOT in screen classes) ⚠️
- [ ] Register dependencies in `injection_container.dart`
- [ ] Add BLoC to `MultiBlocProvider` in `main.dart` ⚠️
- [ ] Test navigation flow
- [ ] Update documentation

#### 5️⃣ Quality Checks
- [ ] Run `flutter analyze` - fix all errors
- [ ] Run `dart format .` - format code
- [ ] Write unit tests for use cases
- [ ] Write widget tests for screens
- [ ] Test error scenarios
- [ ] Manual testing

---

## ✨ Best Practices Summary

### DO ✅
- Follow Clean Architecture layers
- Use BLoC for state management
- Write meaningful variable/class names
- Handle all error cases
- Use dependency injection
- Write tests for business logic
- Keep functions small and focused
- Use const constructors where possible
- Always use the key name **'token'** for auth tokens [[memory:7173260]]
- **Create BOTH remote AND mock data sources for every feature** ⭐
- **Use environment-based configuration (AppConfig) for production apps** ⭐
- **Create separate entry files (main_dev, main_staging, main_prod)**
- **Register all feature BLoCs in MultiBlocProvider in main.dart**
- **Use AppConstants for all API endpoints (never hardcode endpoints)**
- **Return models from data sources, not Map<String, dynamic>**
- **Access response.data from ApiClient, not direct map access**
- **Define all route names in AppRouter class only (never in screen classes)**
- **Always use Request Models for API calls (never hardcode data maps)**

### DON'T ❌
- Mix layers (e.g., importing Flutter in domain)
- Hardcode strings (use constants)
- Ignore linter warnings
- Use `print()` statements (use logging)
- Expose sensitive information in errors
- Create God classes (too many responsibilities)
- Skip error handling
- Use different key names for token storage
- **Create features without mock data sources** ⭐
- **Use simple boolean flags for production apps** ⭐
- **Hardcode API endpoints in data sources**
- **Return Map<String, dynamic> from data sources (use models)**
- **Create new BlocProvider when already registered globally**
- **Define route names in screen classes (use AppRouter only)**
- **Send hardcoded maps in API requests (use request models)**
- **Ship to production without proper environment configuration**

---

## 🎓 Development Workflow

### Complete Step-by-Step Process

```

1. Implement feature (Domain → Data → Presentation)
   ├─> Create entities in domain/entities/
   ├─> Create repository interfaces in domain/repositories/
   ├─> Implement use cases in domain/usecases/
   ├─> Add API endpoints to AppConstants ⚠️
   ├─> Create request models in data/models/ (with toJson) ⚠️
   ├─> Create response models in data/models/ (with fromJson, toJson)
   ├─> Implement REMOTE data source in data/datasources/ ⚠️ REQUIRED
   ├─> Implement MOCK data source in data/datasources/ ⚠️ MANDATORY ⭐
   ├─> Implement local cache data source (only if needed) - Optional
   ├─> Implement repositories in data/repositories/
   ├─> Add mock/remote switch flag in injection_container.dart ⚠️
   ├─> Create BLoC (events, states, bloc) in presentation/bloc/
   ├─> Create UI screens in presentation/screens/
   ├─> Add routes to AppRouter ⚠️
   ├─> Register dependencies in injection_container.dart
   └─> Add BLoC to MultiBlocProvider in main.dart ⚠️

2. Test feature
   ├─> Run flutter analyze
   ├─> Run dart format .
   ├─> Fix linter errors
   ├─> Write unit tests
   ├─> Write widget tests
   └─> Manual testing

3. Code review
   ├─> Check rules.md compliance
   ├─> Verify all ⚠️ points above
   └─> Review test coverage

```

### Common Mistakes to Avoid ⚠️

1. **Not Creating Mock Data Source or Using Simple Flags**
   ```dart
   // ❌ Wrong - Only remote
   sl.registerLazySingleton<ProductRemoteDataSource>(
     () => ProductRemoteDataSourceImpl(apiClient: sl()),
   );
   
   // ⚠️ Okay for small projects, NOT for production
   const bool _useMockData = true;
   sl.registerLazySingleton<ProductRemoteDataSource>(
     () => _useMockData
         ? ProductMockDataSourceImpl()
         : ProductRemoteDataSourceImpl(apiClient: sl()),
   );
   
   // ✅ Correct - Environment-based (PRODUCTION GRADE)
   sl.registerLazySingleton<ProductRemoteDataSource>(
     () => AppConfig.instance.useMockData
         ? ProductMockDataSourceImpl()
         : ProductRemoteDataSourceImpl(apiClient: sl()),
   );
   ```

2. **Hardcoding Routes**
   ```dart
   // ❌ Wrong
   Navigator.pushNamed(context, '/login');
   
   // ✅ Correct
   Navigator.pushNamed(context, AppRouter.login);
   ```

3. **Creating Multiple BLoC Instances**
   ```dart
   // ❌ Wrong - Creating new instance
   BlocProvider(
     create: (_) => sl<AuthBloc>(),
     child: LoginScreen(),
   )
   
   // ✅ Correct - Use existing from MultiBlocProvider
   const LoginScreen() // Access via context.read<AuthBloc>()
   ```

4. **Returning Maps from Data Sources**
   ```dart
   // ❌ Wrong
   Future<Map<String, dynamic>> login();
   
   // ✅ Correct
   Future<AuthResponse> login();
   ```

5. **Hardcoding API Endpoints**
   ```dart
   // ❌ Wrong
   await apiClient.post('/auth/login');
   
   // ✅ Correct
   await apiClient.post(AppConstants.loginEndpoint);
   ```

6. **Sending Hardcoded Maps in API Requests**
   ```dart
   // ❌ Wrong - Hardcoded map
   await apiClient.post(
     AppConstants.loginEndpoint,
     data: {'email': email, 'password': password},
   );
   
   // ✅ Correct - Using request model
   final request = LoginRequestModel(email: email, password: password);
   await apiClient.post(
     AppConstants.loginEndpoint,
     data: request.toJson(),
   );
   ```

7. **Defining Routes in Screen Classes**
   ```dart
   // ❌ Wrong
   class LoginScreen {
     static const routeName = '/login';
   }
   
   // ✅ Correct - In AppRouter only
   class AppRouter {
     static const String login = '/login';
   }
   ```

---

## 📞 Questions?

When in doubt:
1. Check existing features for reference (especially `auth` and `dashboard`)
2. Follow the layer separation strictly
3. Review the **Critical Best Practices** section
4. Check the **Common Mistakes to Avoid** section
5. Ensure all ⚠️ points in checklist are completed

---

## 📚 Quick Reference

### File Locations Reference
```
✅ Routes → lib/core/navigation/app_router.dart
✅ API Endpoints → lib/core/constants/app_constants.dart
✅ BLoC Registration → lib/main.dart (MultiBlocProvider)
✅ Dependencies → lib/core/di/injection_container.dart
✅ Token Key → 'token' (always use this key)
✅ Mock/Remote Switch → lib/core/di/injection_container.dart (_useMockData flag)
```

### Data Source Files Pattern
```
✅ Remote (Required) → feature_remote_datasource.dart
✅ Mock (Mandatory) → feature_mock_datasource.dart ⭐
✅ Cache (Optional) → feature_local_cache_datasource.dart
```

### Environment Configuration (Production Grade)
```
✅ App Config → lib/core/config/app_config.dart ⭐
✅ Dev Entry → lib/main_dev.dart
✅ Staging Entry → lib/main_staging.dart
✅ Prod Entry → lib/main_prod.dart ⭐
✅ See ENVIRONMENT_CONFIG.md for complete guide
```

### Code Snippets Quick Access

**Navigation:**
```dart
Navigator.pushNamed(context, AppRouter.login);
Navigator.pushReplacementNamed(context, AppRouter.dashboard);
```

**BLoC Usage:**
```dart
context.read<AuthBloc>().add(LoginRequested(...));
```

**API Call:**
```dart
final response = await apiClient.post(AppConstants.loginEndpoint, data: data);
final data = response.data as Map<String, dynamic>;
```

**Dependency Injection:**
```dart
// In injection_container.dart
sl.registerFactory(() => FeatureBloc(...));
sl.registerLazySingleton(() => FeatureRepository(...));
```

---

**Remember:** Clean code is not written by following a set of rules. You don't become a software craftsman by learning a list of what to do and what not to do. Professionalism and craftsmanship come from discipline and consistent practice.

**These rules exist to:**
- Maintain consistency across the codebase
- Make onboarding new developers easier
- Reduce bugs through standardized patterns
- Enable faster development through clear guidelines

Happy Coding! 🚀