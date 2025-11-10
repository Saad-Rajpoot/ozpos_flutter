# OZPOS Flutter – Data Access & Offline Behaviour

## Overview

The current Flutter implementation follows a clean architecture stack with BLoC-based presentation, use cases, repositories, and environment-driven data sources. SQLite support is available through `DatabaseHelper`, but at the moment only a subset of features (primarily checkout storage) write to the on-device database. Other feature areas—menu, addons, combos, delivery, etc.—operate against in-memory mock JSON payloads in development and REST APIs in production. There is **no Firebase dependency or sync service** in this repository; the `sync_queue` table defined in the schema is reserved for future work.

## Architecture Components

- **Environment toggle** – `AppConfig` chooses between `development` (mock JSON data) and `production` (remote REST endpoints) during startup, and the dependency container registers the appropriate data sources.  
- **Repository layer** – Each repository wraps a feature data source and relies on `NetworkInfo` to guard network-only implementations; when the device is offline most repositories currently surface a `NetworkFailure`.  
- **SQLite helper** – `DatabaseHelper` provisions tables for menu entities, orders, reservations, printers, cart items, and a `sync_queue`. The helper is injected into the container when a native database factory is available (mobile and desktop).  
- **Mock assets** – Development mode loads realistic JSON fixtures from `assets/**` (for example menu items, combos, orders, reports). This keeps the UI interactive without a backend.  
- **Sync queue placeholder** – The schema already includes a `sync_queue` table, but no runtime service populates or drains it yet. Implementing that queue is part of the future roadmap.

## Database Schema Snapshot

The schema below comes directly from `DatabaseHelper` and reflects the actual tables created today. Notice that business data (menu items, orders, modifiers, tables, reservations, printers, cart items) is defined, along with indexes to support lookups.

```38:229:lib/core/utils/database_helper.dart
    await db.execute('''
      CREATE TABLE menu_items (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        image TEXT,
        base_price REAL NOT NULL,
        tags TEXT,
        requires_customization INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        order_number TEXT NOT NULL UNIQUE,
        order_type TEXT NOT NULL,
        status TEXT NOT NULL,
        table_number TEXT,
        customer_name TEXT,
        customer_phone TEXT,
        customer_address TEXT,
        subtotal REAL NOT NULL,
        tax_amount REAL NOT NULL,
        tip_amount REAL NOT NULL DEFAULT 0,
        total_amount REAL NOT NULL,
        payment_method TEXT,
        payment_status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced_at TEXT,
        retry_count INTEGER NOT NULL DEFAULT 0,
        error_message TEXT
      )
    ''');
```

> ℹ️ `CheckoutLocalDataSource` queries a `metadata` table that is not yet created by `DatabaseHelper`. The table definition or a different persistence strategy still needs to be added before checkout metadata can be stored locally.

## Data Flow

```
┌───────────────┐      ┌────────────┐      ┌─────────────┐      ┌──────────────┐
│ Presentation  │ ---> │  Use Case  │ ---> │ Repository  │ ---> │ Data Source  │
│ (BLoC)        │      │ (dartz)    │      │ (NetworkInfo│      │ (Mock or REST│
│               │      │            │      │  + mapping) │      │  depending)  │
└───────────────┘      └────────────┘      └─────────────┘      └──────────────┘
                                                                    │
                                                                    ├─ Development → JSON fixtures in assets/
                                                                    └─ Production  → REST endpoints via Dio
```

Checkout is the only workflow that currently writes to SQLite:

```
CheckoutBloc → ProcessPaymentUseCase → CheckoutRepositoryImpl
            → CheckoutLocalDataSource.saveOrder() → SQLite `orders`
            → (metadata fetch still TODO)
```

## Implementation Highlights

### Menu loading (BLoC layer)

```69:124:lib/features/menu/presentation/bloc/menu_bloc.dart
  Future<void> _onLoadMenuData(
    LoadMenuData event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());

    final categoriesResult = await getMenuCategories(const NoParams());
    final itemsResult = await getMenuItems(const NoParams());

    final existingCategories = state is MenuLoaded
        ? (state as MenuLoaded).categories
        : <MenuCategoryEntity>[];
    final existingItems =
        state is MenuLoaded ? (state as MenuLoaded).items : <MenuItemEntity>[];

    String? categoriesError;
    String? itemsError;

    final loadedCategories = categoriesResult.fold(
      (failure) {
        categoriesError = _mapFailureToMessage(failure);
        return existingCategories;
      },
      (categories) => categories,
    );

    final loadedItems = itemsResult.fold(
      (failure) {
        itemsError = _mapFailureToMessage(failure);
        return existingItems;
      },
      (items) => items;
    );

    if (loadedCategories.isNotEmpty || loadedItems.isNotEmpty) {
      emit(MenuLoaded(
        categories: loadedCategories,
        items: loadedItems,
      ));
    } else {
      final errorMessage = categoriesError ?? itemsError ?? 'Unknown error';
      emit(MenuError(message: errorMessage));
    }
  }
```

### Repository + Network guard

```20:41:lib/features/menu/data/repositories/menu_repository_impl.dart
  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems() async {
    if (await networkInfo.isConnected) {
      try {
        final items = await menuDataSource.getMenuItems();
        return Right(items.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(
            ServerFailure(message: 'Unexpected error loading menu items: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No network connection'));
    }
  }
```

### Development data source (JSON fixtures)

```14:69:lib/features/menu/data/datasources/menu_mock_datasource.dart
class MenuMockDataSourceImpl implements MenuDataSource {
  static Future<List<MenuCategoryModel>> _getMockCategories() async {
    final jsonString = await rootBundle.loadString(
      'assets/menu_data/menu_items.json',
    );
    final List<dynamic> menuItemsData = json.decode(jsonString);

    final Map<String, dynamic> categoriesMap = {};
    for (final item in menuItemsData) {
      final category = item['category'];
      if (category != null && category['id'] != null) {
        categoriesMap[category['id']] = category;
      }
    }

    final categories = categoriesMap.values.toList()
      ..sort((a, b) => (a['sortOrder'] ?? 0).compareTo(b['sortOrder'] ?? 0));

    return categories.map((category) {
      return MenuCategoryModel(
        id: category['id'],
        name: category['name'],
        description: category['description'],
        image: category['image'],
        isActive: category['isActive'] ?? true,
        sortOrder: category['sortOrder'] ?? 0,
        createdAt:
            DateTime.parse(category['createdAt'] ?? '2025-01-08T10:00:00.000Z'),
        updatedAt:
            DateTime.parse(category['updatedAt'] ?? '2025-01-08T10:00:00.000Z'),
      );
    }).toList();
  }
```

### Checkout persistence (SQLite)

```7:28:lib/features/checkout/data/datasources/checkout_local_datasource.dart
class CheckoutLocalDataSource implements CheckoutDataSource {
  final Database _database;

  CheckoutLocalDataSource({required Database database}) : _database = database;

  @override
  Future<CheckoutEntity> saveOrder(OrderModel orderModel) async {
    await _database.insert('orders', orderModel.toJson());
    return CheckoutData.fromJson(
      {
        'orders': (await _database
                .query('orders', where: 'id = ?', whereArgs: [orderModel.id]))
            .map((json) =>
                OrderModel.fromJson(json as Map<String, dynamic>).toEntity())
            .toList(),
        'metadata': CheckoutData.fromJson(
          (await _database.query('metadata'))[0],
        ).toEntity(),
      },
    ).toEntity();
  }
}
```

## Current Offline Behaviour

- Most repositories return a `NetworkFailure` if the device is offline (`NetworkInfo` simply wraps `connectivity_plus`). There is no caching fallback for menu/addon/combos/orders data yet.  
- Checkout writes to SQLite, but additional tables (e.g. `metadata`) still need to be created to avoid runtime errors.  
- The `sync_queue` table is unused; no background worker persists or replays operations.  
- Because Firebase packages are absent from `pubspec.yaml`, any references to Firestore in earlier documentation are now obsolete. Future synchronization will need to target either the REST API or a yet-to-be-added service.

## Startup & Environment

```18:54:lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = SentryBlocObserver();

  AppConfig.instance.initialize(
    environment:
        AppEnvironment.development,
  );

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await di.init();
  _setupErrorHandlers();

  AppConfig.instance.printConfig();
  SentryConfig.printConfig();

  if (SentryConfig.enableSentry) {
    await SentryFlutter.init(
      _configureSentry,
      appRunner: () => runApp(const OzposApp()),
    );
  } else {
    runApp(const OzposApp());
  }
}
```

### Switching environments

1. Change `AppConfig.instance.initialize(environment: …)` in `main.dart`.  
2. Optionally pass `--dart-define=API_BASE_URL=https://custom-url` when running in production mode.  
3. In production the DI container registers remote data sources that use `Dio` + `ApiClient`. In development it loads JSON fixtures.

### Running the app

```bash
flutter pub get
flutter run        # uses the default device
flutter run -d chrome
flutter run -d windows
```

No file renames or manual swaps (`main_new.dart`, etc.) are required—the repo already contains the correct entry point.

## Planned Enhancements

- Introduce local caching for read paths so menu/addon data remains available offline. Options include hydrating SQLite tables from mock data or adding Hive/objectbox for lighter weight storage.  
- Implement a real sync worker that writes to and drains the existing `sync_queue`, likely targeting the REST API first.  
- Add migrations for the checkout metadata table and any additional entities stored locally.  
- Evaluate background connectivity monitoring to trigger sync retries automatically once a network comes back.

## Key Files

- `lib/core/di/injection_container.dart` – environment-aware dependency registration  
- `lib/core/utils/database_helper.dart` – SQLite schema and migrations  
- `lib/core/config/app_config.dart` – environment and API configuration  
- `lib/features/menu/**` – example of BLoC + repository + data source wiring  
- `lib/features/checkout/data/datasources/checkout_local_datasource.dart` – current SQLite write usage  
- `assets/**` – mock JSON payloads consumed in development

---

**Status:** SQLite schema provisioned; offline caching and sync service still pending  
**Last Reviewed:** Current session  
