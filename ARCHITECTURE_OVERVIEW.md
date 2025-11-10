# OZPOS Flutter – Architecture Overview

This document explains the production architecture that powers the OZPOS Flutter codebase. It captures the guiding principles (Clean Architecture, SOLID, separation of concerns), the BLoC state management strategy, folder conventions, and the Mock → Local → Remote data-source pipeline that keeps the app consistent across environments and platforms.

---

## 1. Guiding Principles

| Principle | What it Means in OZPOS | Key References |
|-----------|-----------------------|----------------|
| **Clean Architecture** | Each feature is sliced into presentation, domain, and data layers with explicit boundaries. | `lib/features/<feature>/{presentation,domain,data}` |
| **SOLID** | Small, testable classes with clear responsibilities and dependency inversion via abstractions. | `lib/core/base`, `lib/core/di/injection_container.dart` |
| **Separation of Concerns** | Cross-cutting code (config, navigation, analytics, error handling) lives in `lib/core`, while business capabilities live in `lib/features`. | `lib/core/*`, `lib/features/*` |
| **BLoC State Management** | Reactive event/state flows handle presentation logic, with per-feature blocs injected on navigation. | `lib/core/base/base_bloc.dart`, feature `bloc/` folders |
| **Environment Awareness** | Behavior toggles between Mock → Local → Remote sources through `AppConfig` and DI factories. | `lib/core/config/app_config.dart`, `lib/core/di/injection_container.dart` |

---

## 2. Clean Architecture in Practice

```
┌────────────────────────────────────────────┐
│ Presentation Layer (Widgets, Screens, BLoC)│
│  • Reads from Domain entities              │
│  • Dispatches events / renders states      │
└────────────────────────────────────────────┘
                ▲
                │
┌────────────────────────────────────────────┐
│ Domain Layer (Use Cases, Entities, Repos)   │
│  • Pure Dart, no Flutter imports            │
│  • Business rules + abstractions            │
└────────────────────────────────────────────┘
                ▲
                │
┌────────────────────────────────────────────┐
│ Data Layer (Repositories, Data Sources)     │
│  • Talks to Mock / Local / Remote providers │
│  • Converts models ⇆ entities               │
└────────────────────────────────────────────┘
```

### 2.1 Presentation Layer
- **Widgets & Screens:** Live under `lib/features/<feature>/presentation/{screens,widgets}` and compose UI from domain entities.
- **BLoC Classes:** Provide stateful orchestration with events and immutable states, e.g. `lib/features/checkout/presentation/bloc/checkout_bloc.dart`.
- **Navigation:** Centralized via `AppRouter` and `NavigationService` so screens do not manipulate `Navigator` directly.

### 2.2 Domain Layer
- **Entities:** Immutable, serialization-free descriptions of business concepts (`lib/features/menu/domain/entities/menu_item_entity.dart`).
- **Use Cases:** Encapsulate actions (`lib/features/menu/domain/usecases/get_menu_items.dart`) and always return `Either<Failure, T>` from `lib/core/base/base_usecase.dart`.
- **Repository Contracts:** Abstract interfaces consumed by use cases (`lib/features/checkout/domain/repositories/checkout_repository.dart`).

### 2.3 Data Layer
- **Repositories (Implementations):** Bridge domain interfaces to data sources while handling failures (`lib/features/menu/data/repositories/menu_repository_impl.dart`).
- **Data Sources:** Split per environment (mock JSON, SQLite, remote API) under `data/datasources`.
- **Models:** Handle serialization and caching, distinct from domain entities.

---

## 3. SOLID & Separation of Concerns

- **Single Responsibility:** Each class focuses on one job—e.g. `CartBloc` manages cart state only, while `CalculateTotalsUseCase` focuses on pricing rules.
- **Open/Closed:** Feature modules extend functionality by adding use cases or data sources without modifying existing contracts.
- **Liskov Substitution:** Data source interfaces (`MenuDataSource`, `CheckoutDataSource`) ensure any concrete implementation can replace another.
- **Interface Segregation:** Use cases expose minimal inputs/outputs; consumers do not depend on unused members.
- **Dependency Inversion:** Presentation depends on abstractions (use cases, repositories). Implementations are supplied through GetIt (`lib/core/di/injection_container.dart`).
- **Cross-Cutting Separation:** Configuration, routing, error handling, and analytics live in `lib/core`, keeping features clean.

---

## 4. BLoC State Management Strategy

- **Base Contracts:** `BaseBloc`, `BaseEvent`, `BaseState` (`lib/core/base/base_bloc.dart`) provide consistent equality and reduce boilerplate.
- **Feature Scoping:** Global blocs (e.g. `CartBloc`) are injected once in `main.dart`, while feature-specific blocs are created lazily in `AppRouter`.
- **Observability:** `SentryBlocObserver` (`lib/core/utils/sentry_bloc_observer.dart`) captures transitions and errors for telemetry.
- **Testing:** Small, deterministic blocs isolate UI reactions from business rules. Use cases are easily mocked because they are injected as interfaces.
- **Error Surfacing:** Failures bubble through states (e.g. `CheckoutError`) instead of throwing inside widgets.

---

## 5. Folder Structure Convention

```
lib/
├── core/
│   ├── base/            # Shared abstractions (BLoC, UseCase)
│   ├── config/          # Environment & Sentry config
│   ├── constants/       # Theme & sizing constants
│   ├── di/              # GetIt registration
│   ├── errors/          # Exceptions & Failures
│   ├── navigation/      # AppRouter + NavigationService
│   ├── network/         # ApiClient, interceptors, connectivity
│   ├── services/        # Cross-cutting services (Sentry, etc.)
│   ├── theme/           # Light/Dark themes
│   └── utils/           # Helpers (database helper, exception helper)
└── features/
    └── <feature name>/
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

This shape applies uniformly to features such as `menu`, `checkout`, `addons`, `tables`, `orders`, `reports`, and more, enabling teams to navigate quickly and predictably.

---

## 6. Mock → Local → Remote Data Source Pipeline

### 6.1 Data Source Tiers

1. **Mock** (`*_mock_datasource.dart`):  
   - Loads deterministic JSON fixtures from `assets/*`.  
   - Used in development to unblock UI work without live services.

2. **Local** (`*_local_datasource.dart`):  
   - Reads/writes SQLite via `sqflite` and `DatabaseHelper`.  
   - Powers offline-first flows and caching.

3. **Remote** (`*_remote_datasource.dart`):  
   - Uses `ApiClient` (Dio + interceptors) for REST endpoints.  
   - Handles network/server errors through `ExceptionHelper`.

### 6.2 Environment-Aware Selection

`AppConfig` (`lib/core/config/app_config.dart`) exposes the active environment via `AppEnvironment`. The DI container chooses the appropriate data source at runtime:

```dart
@@@ lib/core/di/injection_container.dart
sl.registerLazySingleton<MenuDataSource>(() {
  if (AppConfig.instance.environment == AppEnvironment.development) {
    return MenuMockDataSourceImpl();
  } else {
    return MenuRemoteDataSourceImpl(apiClient: sl());
  }
});
```

If a desktop build runs without a database, DI automatically falls back to mock sources (see `_initCheckout`), ensuring the app still functions.

### 6.3 Repository Mediation

Repositories (e.g. `MenuRepositoryImpl`) wrap data source calls, map models to domain entities, and surface failures via typed `Failure` objects. Domain use cases never know which tier provided the data.

---

## 7. Dependency Injection & Configuration

- **Service Locator:** GetIt registrations in `injection_container.dart` are grouped per feature and invoked after `AppConfig.initialize` in `main.dart`.
- **Configuration:** `AppConfig` and `SentryConfig` centralize environment toggles, API base URLs, logging flags, and telemetry settings.
- **Startup Flow:** `main.dart` initializes Sentry, sets the global BLoC observer, configures platform databases, loads DI, and then boots the app through `AppRouter`.

---

## 8. Extending the Architecture

When adding a new capability:

1. **Create a feature folder** with `data`, `domain`, and `presentation` subdirectories.
2. **Define domain contracts** (`entities`, `repositories`, `usecases`) before writing UI.
3. **Implement data sources** for mock/local/remote needs; wire them in DI based on environment.
4. **Expose repositories** that map between models and domain entities while handling failures.
5. **Add presentation logic** via BLoC, keeping widgets declarative and stateless where possible.
6. **Register DI + Routes:** Update `injection_container.dart` and, if user-facing, `AppRouter`.
7. **Document unique patterns** in the `docs/` folder (see `NAVIGATION_ARCHITECTURE.md`, `OFFLINE_FIRST_GUIDE.md`) to keep the knowledge base living.

Following these steps keeps the app consistent with the established architecture and ensures new team members understand how to scale the system responsibly.

---

## 9. Related Documentation

- `docs/NAVIGATION_ARCHITECTURE.md` – Deep dive into routing and navigation patterns.
- `docs/OFFLINE_FIRST_GUIDE.md` – Details on sync queues, SQLite schema, and conflict resolution.
- `docs/ADDON_MANAGEMENT_IMPLEMENTATION.md` – Example of a feature built end-to-end using these architectural conventions.

Use this overview as the starting point for architectural decisions, and keep it updated alongside major refactors or new cross-cutting patterns.

