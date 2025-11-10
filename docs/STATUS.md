# OZPOS Flutter – Current Status

## ✅ Completed Foundations

- **Clean architecture & state management** – Presentation uses BLoC throughout (`MenuBloc`, `CartBloc`, `CheckoutBloc`, etc.) with environment-aware dependency injection in `lib/core/di/injection_container.dart`.  
- **Environment toggling** – `AppConfig` switches between mock JSON data (development) and REST services (production), allowing the app to boot without a backend while keeping the HTTP client ready.  
- **Cross-feature wiring** – Dashboard routing, menu browsing, checkout flow, addons, combos, orders, tables, delivery, reservations, reports, settings, printing, and customer-display screens are all registered in `AppRouter`. Each route spins up the relevant BLoC and loads mock data successfully in dev mode.  
- **SQLite schema ready** – `DatabaseHelper` provisions menu, order, table, reservation, printer, cart, and sync queue tables. Checkout already writes to SQLite; other features still use in-memory mocks.  
- **Theming & layout** – Light/dark themes, responsive breakpoints, gradients, and shared design tokens are consolidated in `lib/core/theme/app_theme.dart` and associated constants.  
- **Instrumentation** – Sentry integration, global error handlers, and navigation observers are wired in `main.dart`. Connectivity checks, retry interceptor, and token-aware headers are available via `ApiClient`.

## 🚧 Gaps & High-Priority Follow-Up

- Implement real offline caching for read flows (menu/addons/combos/orders) and reconcile the missing `metadata` table used by checkout persistence.  
- Build a background sync worker (or REST sync path) that uses the existing `sync_queue` schema.  
- Replace mock JSON loaders with real API calls in production mode, adding DTO-to-entity mapping tests.  
- Expand automated testing (unit tests for repositories and BLoCs, widget tests for primary screens).  
- Harden navigation flows with loading/empty/error states once APIs are connected.

## 🏛 Architecture Snapshot

```
┌──────────────────────────────────────────────┐
│                 Flutter UI                   │
│      (Screens + Widgets controlled by BLoC)  │
└─────────────────┬────────────────────────────┘
                  │
                  ↓
┌──────────────────────────────────────────────┐
│            Feature Use Cases                 │
│  (dartz Either + BaseUseCase abstractions)   │
└─────────────────┬────────────────────────────┘
                  │
                  ↓
┌──────────────────────────────────────────────┐
│            Repository Implementations        │
│  - NetworkInfo gate keeps online calls       │
│  - Maps models <-> domain entities           │
└─────────────────┬───────────────┬────────────┘
                  │               │
                  ↓               ↓
        ┌────────────────┐  ┌───────────────┐
        │  Mock JSON     │  │   REST API    │
        │ (development)  │  │ (production)  │
        └────────────────┘  └───────────────┘
                 │
                 ↓
        ┌────────────────────────────┐
        │ SQLite via DatabaseHelper  │
        │ (currently write-heavy for │
        │ checkout; read caching TBD)│
        └────────────────────────────┘
```

## 🔄 Data Flow Examples

### Menu browse (development mode)
`MenuScreen` → `MenuBloc.LoadMenuData` → use cases → `MenuRepositoryImpl` → `MenuMockDataSourceImpl` → JSON fixtures → UI updates.

### Checkout submit (desktop/mobile)
`CheckoutBloc.ProcessPayment` → `CheckoutRepositoryImpl` → `CheckoutLocalDataSource` → SQLite `orders` table, then UI success state. Metadata read still requires a table definition.

## 📊 Current Metrics

| Metric | Value (Nov 2025) |
| ------ | ---------------- |
| Dart files | 380 |
| Dart LOC | 56,899 |
| Feature modules | 11 (menu, checkout, addons, combos, orders, tables, delivery, reservations, reports, settings, printing, customer display) |
| BLoC implementations | 20+ |
| JSON fixtures | 40+ across assets/ |
| SQLite tables | 10 (including sync queue & cart items) |
| Flutter/Dart dependencies | 18 runtime / 3 dev |

## 🎯 What Works Today

- Dashboard navigation with feature entry tiles.  
- Menu browsing with categories, filters, and cart interactions backed by mock data.  
- Cart state handled globally via `CartBloc` (quantities, totals, clear/reset).  
- Checkout flow including payment selection, tips, split payments, and SQLite persistence (orders table).  
- Addon, combo, orders, tables, delivery, reservations, reports, settings, printing, and customer-display screens render using mock payloads and respond to refresh events.  
- Sentry logging, connectivity detection, retryable API client, and environment logging.

## 🐞 Known Issues / Risks

1. **Offline read gap** – Without caching, most repositories error when offline (`NetworkFailure`).  
2. **Checkout metadata table missing** – `CheckoutLocalDataSource` queries a `metadata` table not yet created.  
3. **Sync queue idle** – Table exists but no service populates it; offline writes beyond checkout are not captured.  
4. **Mock/real divergence** – Ensure JSON fixtures stay aligned with eventual API contracts to avoid domain mismatches.  
5. **Test coverage TODO** – Limited automated tests; regressions are possible without unit/widget safeguards.

## 🚀 Running the App

```bash
flutter pub get

# default environment: development (mock data)
flutter run

# choose a specific target
flutter run -d chrome
flutter run -d windows

# switch to production-style wiring
flutter run --dart-define=APP_ENV=production
```

`AppConfig.instance.initialize(...)` in `main.dart` controls the environment. For production runs, configure `API_BASE_URL` (and future auth keys) via `--dart-define`.

## 🔌 Dependency Snapshot

- **State & DI**: `flutter_bloc`, `bloc`, `get_it`, `dartz`.  
- **Data**: `sqflite`, `sqflite_common_ffi`, `path`, `path_provider`, `shared_preferences`, `dio`, `connectivity_plus`, `uuid`.  
- **UI**: `cached_network_image`, `shimmer`, `intl`, `fl_chart`, `image_picker`.  
- **Observability**: `sentry_flutter`, `package_info_plus`.  
- **Dev/Test**: `flutter_test`, `flutter_lints`, `mocktail`.

## 📚 Reference Docs

- `README.md` – high-level project summary.  
- `QUICKSTART.md` – environment setup and run instructions.  
- `OFFLINE_FIRST_GUIDE.md` – detailed view of the current data layer and gaps.  
- `FLUTTER_CONVERSION_GUIDE.md` – notes from the original migration effort.

## 🔭 Next Session Focus

1. Add SQLite caching (or alternative persistence) for menu/addon data so the UI functions offline.  
2. Implement sync queue writers and a background task to reconcile pending operations.  
3. Replace mock sources with real API calls in production mode and backfill missing DTOs.  
4. Create end-to-end tests for core user flows (menu → cart → checkout).  
5. Address checkout metadata persistence and seed data for tables/reservations.

---

**Status:** Foundations complete, data-sync & offline read scenarios pending  
**Last Updated:** Current session  
