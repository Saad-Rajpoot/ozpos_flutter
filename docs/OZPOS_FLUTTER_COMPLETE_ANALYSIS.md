# OZPOS Flutter – Complete Analysis (November 2025)

## 1. Architecture Overview

- **Pattern**: Clean architecture with BLoC presentation, use cases, repositories, and data sources.  
- **Environment toggle**: `AppConfig` switches between development (mock JSON assets) and production (REST API).  
- **Navigation**: Centralised in `AppRouter`, using `NavigationService` and route-specific BLoCs.  
- **Dependency injection**: `lib/core/di/injection_container.dart` registers data sources, repositories, use cases, and presentation BLoCs per feature.  
- **Storage**: `DatabaseHelper` provisions tables for menu, modifiers, orders, tables, reservations, printers, cart items, and an unused `sync_queue`. Checkout already writes to SQLite.  
- **Observability**: Sentry integration, connectivity tracking, retry interceptor for `Dio`, and structured error handling.

## 2. Feature Coverage

| Feature | Status | Notes |
| ------- | ------ | ----- |
| Dashboard | ✅ | Gradient tiles, responsive layout, navigation to every module. |
| Menu | ✅ | Menu grid, filtering, search, mock data loaders. |
| Menu wizard | ✅ | 5-step editor with `MenuEditBloc`, addon integration, draft saving. |
| Cart & checkout | ✅ | `CartBloc` singleton, tips, split payments, loyalty, vouchers, SQLite persistence. |
| Addons & combos | ✅ | CRUD flows, mock data sources, validation logic. |
| Orders | ✅ | Status filtering, mock orders feed, refresh. |
| Tables & reservations | ✅ | Floor layout, state filters, reservation cards. |
| Delivery | ✅ | Kanban board with mock driver/job data. |
| Reports | ✅ | Metrics cards, charts via `fl_chart`, mock analytics. |
| Settings | ✅ | Categorised settings list with mock configuration data. |
| Printing & docket designer | ✅ | ESC/POS integration stubs and visual template editor. |
| Customer display | ✅ | Standalone BLoC screen launched as a modal route. |

All features operate with mock fixtures in development mode; production mode swaps repositories to remote REST data sources.

## 3. Dependencies (Pubspec)

- **State/DI**: `flutter_bloc`, `bloc`, `get_it`, `dartz`, `equatable`.  
- **Data**: `sqflite`, `sqflite_common_ffi`, `path`, `path_provider`, `shared_preferences`, `uuid`.  
- **Network**: `dio`, `connectivity_plus`.  
- **UI**: `cupertino_icons`, `cached_network_image`, `shimmer`, `image_picker`, `fl_chart`, `fluttertoast`, `intl`.  
- **POS tooling**: `esc_pos_printer`, `esc_pos_utils`.  
- **Observability**: `sentry_flutter`, `package_info_plus`.  
- **Dev**: `flutter_test`, `flutter_lints`, `mocktail`.  
- **Firebase packages**: none.

## 4. Offline & Sync Readiness

- SQLite schema created for all key entities.  
- Checkout writes orders locally; other repositories currently fetch from mock/remote sources only.  
- `sync_queue` table is unused; introduce a worker to record and replay offline operations.  
- Need to add missing `metadata` table for checkout persistence.  
- Implement caching for menu/addon/combos/orders to support offline browsing.

## 5. Testing & Quality

- **Current coverage**: Manual testing + Sentry instrumentation.  
- **To add**: Unit tests for repositories/use cases, widget tests for dashboard/menu/checkout, integration test for end-to-end order flow.  
- **Tooling**: `flutter_lints` baseline lint rules, `mocktail` available for test doubles.

## 6. Performance Considerations

- Mock data loading is synchronous; add pagination or caching for production feeds.  
- ESC/POS packages add size; consider feature flags for builds without printers.  
- Image caching handled by `cached_network_image`; ensure CDN caching headers when backend goes live.  
- Keep `connectivity_plus` + retry interceptor tuned to avoid excessive retries on flaky networks.

## 7. Security & Config

- Sentry DSN and release info supplied via `SentryConfig`; ensure `--dart-define` values in CI.  
- Store API base URLs and tokens using `AppConfig` + `SharedPreferences`.  
- No Firebase credentials required; integration can be added later if needed.  
- Add dependency audit (e.g. Dependabot or `flutter pub outdated`) to CI to monitor package updates.

## 8. Roadmap

1. Implement offline caching + sync queue worker.  
2. Connect to production REST APIs (auth, DTO mapping, error handling).  
3. Add checkout metadata table/migrations.  
4. Expand automated testing for critical flows.  
5. Configure Sentry + CI/CD pipelines for release builds.  
6. Profile performance once real data is wired.

---

The Flutter implementation is feature complete with mock data, a clean architecture stack, and cross-platform readiness. Remaining work focuses on data durability (caching/sync), backend integration, and automated validation to prepare for production deployment. ✅