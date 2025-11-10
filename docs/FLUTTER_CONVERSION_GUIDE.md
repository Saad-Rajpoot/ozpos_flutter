# OZPOS React → Flutter Conversion Guide

## Overview

The React/TypeScript OZPOS experience has been ported to Flutter with a clean architecture stack and BLoC-driven presentation. This guide documents the structure now living in `ozpos_flutter/`, the feature parity achieved, and the remaining work needed to finish the migration.

## ✅ Converted Foundations

- **Architecture** – Presentation uses `flutter_bloc`, the domain layer exposes use cases (`dartz` `Either`), and data sources (mock JSON or REST) are wired via dependency injection.
- **Environment toggle** – `AppConfig` selects development (mock assets) or production (REST API) environments at startup, allowing instant local runs without a backend.
- **Features** – Dashboard, menu, checkout, addons, combos, orders, tables, delivery, reservations, reports, settings, printing, docket designer, addon management, and customer display screens are all in place with mock data.
- **SQLite schema** – `DatabaseHelper` provisions tables for menu entities, orders, modifiers, tables, reservations, printers, cart items, and a sync queue. Checkout already writes orders locally.
- **Design system** – Light/dark themes, gradients, spacing, typography, shadows, and responsive breakpoints are consolidated in `lib/core/theme` and `lib/core/constants`.
- **Observability & tooling** – Sentry reporting, connectivity checks, retryable `Dio` HTTP client, and navigation logging are enabled from `main.dart`.

## 🎒 Key Dependencies

| Area | Packages |
| ---- | -------- |
| State & DI | `flutter_bloc`, `bloc`, `get_it`, `dartz` |
| Data | `sqflite`, `sqflite_common_ffi`, `path`, `path_provider`, `shared_preferences`, `dio`, `connectivity_plus`, `uuid` |
| UI | `cached_network_image`, `shimmer`, `fl_chart`, `intl`, `image_picker` |
| Observability | `sentry_flutter`, `package_info_plus` |
| Dev/Test | `flutter_test`, `flutter_lints`, `mocktail` |

No Firebase packages are present; future sync will target REST endpoints (or Firebase if reintroduced).

## 📁 Directory Structure (2025)

```
lib/
├── core/
│   ├── base/                 # BaseBloc, BaseState, BaseUseCase
│   ├── config/               # AppConfig, SentryConfig
│   ├── constants/            # UI + API constants
│   ├── di/                   # GetIt registrations
│   ├── navigation/           # NavigationService + AppRouter
│   ├── network/              # ApiClient, retry interceptor, NetworkInfo
│   ├── theme/                # AppTheme + design tokens
│   └── utils/                # DatabaseHelper, helpers
├── features/
│   ├── menu/
│   │   ├── data/             # Datasources, models, repository impl
│   │   ├── domain/           # Entities, repositories, use cases
│   │   └── presentation/     # Bloc, screens, widgets
│   ├── checkout/
│   ├── addons/
│   ├── combos/
│   ├── orders/
│   ├── tables/
│   ├── delivery/
│   ├── reservations/
│   ├── reports/
│   ├── settings/
│   ├── printing/
│   └── customer_display/
└── main.dart                 # Bootstrap (AppConfig, DI, Sentry, router)
assets/
├── menu_data/
├── checkout_data/
├── orders_data/
└── … (mock datasets for each feature)
```

This layout mirrors the clean architecture pattern (data → domain → presentation) per feature while sharing cross-cutting infrastructure inside `core/`.

## 🔄 Feature Mapping

| React module | Flutter feature | Status | Notes |
| ------------ | --------------- | ------ | ----- |
| Dashboard tiles | `features/dashboard` | ✅ | Gradients, navigation wired |
| Menu browse/editor | `features/menu` | ✅ | BLoC + wizard, mock data |
| Cart & checkout | `features/checkout` | ✅ | CartBloc global, CheckoutBloc handles flow, writes to SQLite |
| Addons manager | `features/addons` | ✅ | Mock data, BLoC |
| Combos | `features/combos` | ✅ | CRUD editor with multi-BLoC wiring |
| Orders board | `features/orders` | ✅ | Loads mock JSON |
| Tables & reservations | `features/tables`, `features/reservations` | ✅ | Floor view, availability |
| Delivery tracking | `features/delivery` | ✅ | Mock drivers/jobs |
| Reports & analytics | `features/reports` | ✅ | Uses `fl_chart` with mock stats |
| Settings | `features/settings` | ✅ | Category list from JSON |
| Printing & docket | `features/printing`, `features/docket` | ✅ | Mock data, ESC/POS stubs |
| Customer display | `features/customer_display` | ✅ | Popup screen, BLoC |

All features are currently powered by mock data in development mode. Production mode switches repositories to remote data sources backed by the shared `ApiClient`.

## 🧩 Core Implementation Patterns

### BLoC orchestration

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

### Environment-driven DI

```118:218:lib/core/di/injection_container.dart
Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  try {
    final database = await DatabaseHelper.database;
    sl.registerLazySingleton<Database>(() => database);
  } catch (_) {
    // Web path: database not available
  }

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: Connectivity()),
  );

  sl.registerLazySingleton(
    () => api_client.ApiClient(
      sharedPreferences: sl(),
      baseUrl: AppConfig.instance.baseUrl,
    ),
  );

  await _initMenu(sl);
  await _initCart(sl);
  await _initCheckout(sl);
  // ... other feature initialisers
}
```

Each `_initFeature` function registers mock or remote data sources depending on `AppConfig.instance.environment`, then wires repositories, use cases, and BLoCs.

### Mock data sources

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

### SQLite persistence

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

> ⚠️ Action item: `DatabaseHelper` does not yet create the `metadata` table expected here. Add migrations or adjust the data source before shipping.

### Navigation orchestration

```86:206:lib/core/navigation/app_router.dart
static Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments as Map<String, dynamic>?;

  switch (settings.name) {
    case dashboard:
      return MaterialPageRoute(
        builder: (_) => BlocProvider<MenuBloc>(
          create: (_) => di.sl<MenuBloc>()..add(const LoadMenuData()),
          child: const DashboardScreen(),
        ),
        settings: settings,
      );
    case checkout:
      return MaterialPageRoute(
        builder: (_) => BlocProvider<CheckoutBloc>(
          create: (_) => di.sl<CheckoutBloc>(),
          child: const CheckoutScreen(),
        ),
        settings: settings,
      );
    // ... other routes
    default:
      return MaterialPageRoute(
        builder: (_) => const ErrorScreen(),
        settings: settings,
    );
  }
}
```

## 🔧 React → Flutter Concept Mapping

| React/TypeScript | Flutter equivalent |
| ---------------- | ------------------ |
| Context + reducers | `BlocProvider` + `BlocBuilder` / `Cubit` |
| Axios + interceptors | `Dio` + custom interceptors in `ApiClient` |
| Redux store | Feature-specific BLoCs + `GetIt` repositories |
| Tailwind gradients | `AppTheme` color system + `LinearGradient` |
| LocalStorage | `SharedPreferences`, SQLite |
| Multi-step wizard | `MenuItemWizardScreen` + `MenuEditBloc` |
| Toast notifications | `ScaffoldMessenger`, `SnackBar` |

## 🔜 Remaining Work

1. **Offline read path** – hydrate SQLite tables from assets or network responses so menu/addon/combos data remains available if connectivity drops.
2. **Sync queue engine** – the schema is ready, but a background service must write to and flush the queue to achieve eventual consistency.
3. **API integration** – finalize REST endpoints, extend models, and switch production DI registrations from mock to remote data sources. Add contract tests to guard JSON shape.
4. **Checkout metadata** – add the missing table/migration in `DatabaseHelper` and seed initial metadata rows.
5. **Testing** – add unit tests for repositories/use cases, widget tests for dashboard/menu/checkout, and integration tests for end-to-end ordering.
6. **Performance polish** – audit large widget rebuilds, consider pagination for heavy lists, and enable caching for images/assets.

## 🧪 Validation Checklist

- [ ] Menu categories/items load via BLoC with mock data.
- [ ] Cart persists through navigation (CartBloc singleton).
- [ ] Checkout saves orders to SQLite without runtime errors.
- [ ] Menu wizard (`MenuItemWizardScreen`) supports create/edit/duplicate/draft flows.
- [ ] All AppRouter destinations launch successfully.
- [ ] Sentry captures handled/unhandled errors when enabled.
- [ ] Production build runs with `APP_ENV=production` and hits configured base URL.

## 🐛 Debugging Tips

- Use `flutter run --verbose` for network/DI issues.
- Check `Connectivity().checkConnectivity()` output when diagnosing offline failures.
- Inspect `ozpos.db` via SQLite browser (see `OFFLINE_FIRST_GUIDE.md`) to confirm table schemas.
- For BLoC debugging, enable `Bloc.observer = SentryBlocObserver()` and watch console logs.
- Mock data mishaps often surface as JSON decode errors—verify assets and update models accordingly.

## 📦 Build & Deploy

| Target | Command | Notes |
| ------ | ------- | ----- |
| Android | `flutter build apk` | Configure signing in `android/app` |
| iOS | `flutter build ipa` | Requires Xcode + provisioning profiles |
| Web | `flutter build web` | Deploy `build/web` to hosting of choice |
| Windows | `flutter build windows` | Uses sqflite via FFI |
| macOS/Linux | `flutter build macos` / `linux` | Ensure desktop support enabled |

Remember to set `--dart-define=APP_ENV=production` (and other secrets) for production builds.

## 📚 Supplemental Docs

- `OFFLINE_FIRST_GUIDE.md` – Data layer & persistence deep dive.
- `QUICKSTART.md` – High-level steps to run and extend the app.
- `STATUS.md` – Current milestones, metrics, and roadmap.
- `MENU_EDITOR_WIZARD_IMPLEMENTATION.md` – Detailed wizard implementation notes.

---

The conversion now mirrors the original React experience with a scalable Flutter architecture. Focus next on plugging in real data sources, completing offline behaviour, and shipping automated tests to keep the codebase stable. 🎯
