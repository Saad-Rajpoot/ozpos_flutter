# OZPOS Flutter – Project Analysis Report (November 2025)

## 1. Project Snapshot

- **Platform coverage**: iOS, Android, Web, Windows, macOS, Linux  
- **Architecture**: Clean architecture (BLoC + use cases + repositories + data sources)  
- **Environment toggle**: `AppConfig` switches between mock JSON data (development) and REST API (production)  
- **Storage**: SQLite schema provisioned via `DatabaseHelper`; checkout writes orders locally  
- **Observability**: Sentry integration, connectivity monitoring, retry interceptor in `ApiClient`  
- **Dependencies**: 24 runtime packages (no Firebase), 3 dev packages  
- **UI/UX**: Shared design system (gradients, typography, spacing, responsive breakpoints)

## 2. Feature Status

| Feature | Status | Notes |
| ------- | ------ | ----- |
| Dashboard | ✅ | Gradient navigation tiles with responsive layout |
| Menu & Menu Wizard | ✅ | Menu browsing, filtering, search, 5-step wizard with `MenuEditBloc` |
| Cart & Checkout | ✅ | `CartBloc` singleton, checkout flow with tips, loyalty, vouchers, split payments, SQLite persistence |
| Addons & Combos | ✅ | CRUD flows, mock data sources, validation logic |
| Orders | ✅ | Status filtering, mock data feed, refresh actions |
| Tables & Reservations | ✅ | Floor view, status indicators, reservation cards |
| Delivery | ✅ | Kanban board representing order pipeline |
| Reports | ✅ | KPIs and charts via `fl_chart`, mock analytics |
| Settings | ✅ | Categorised settings list with mock configuration data |
| Printing & Docket | ✅ | ESC/POS integration stubs, visual docket editor |
| Customer Display | ✅ | Modal route with dedicated BLoC |

## 3. Dependency Overview

| Category | Packages |
| -------- | -------- |
| State & DI | `flutter_bloc`, `bloc`, `get_it`, `dartz`, `equatable` |
| Data & Storage | `sqflite`, `sqflite_common_ffi`, `path`, `path_provider`, `shared_preferences`, `uuid` |
| Networking & Observability | `dio`, `connectivity_plus`, `sentry_flutter`, `package_info_plus` |
| UI & Media | `cupertino_icons`, `cached_network_image`, `shimmer`, `image_picker`, `fl_chart`, `fluttertoast`, `intl` |
| POS Tooling | `esc_pos_printer`, `esc_pos_utils` |
| Dev | `flutter_test`, `flutter_lints`, `mocktail` |

## 4. Offline & Data Readiness

- SQLite tables: menu, modifiers, orders, order_items, tables, reservations, printers, cart_items, sync_queue.  
- Checkout persistence implemented; other repositories currently fetch mock/remote data only.  
- Sync queue is unused—needs a background worker to record and replay offline changes.  
- Checkout metadata table still needs to be added to `DatabaseHelper`.  
- Implement caching for menu/addon/combos/orders to support offline browsing.

## 5. Testing & Quality

- Linting: `flutter analyze` passes.  
- Testing: Minimal automated coverage; use `flutter_test` + `mocktail` for unit/widget/integration tests.  
- Suggested tests: Repositories/use cases, menu BLoC, checkout flow, sync queue processing, smoke test for navigation routes.

## 6. Performance Considerations

- Mock data loads synchronously—introduce pagination/lazy loading once connected to REST APIs.  
- ESC/POS packages add size; consider feature flags for builds without printer support.  
- Cached images handled via `cached_network_image`; confirm backend sends cache headers.  
- Ensure retry interceptor avoids aggressive retries when offline.

## 7. Risks & Mitigation

| Risk | Mitigation |
| ---- | ---------- |
| Offline read gap | Implement caching and sync worker before live launch |
| API contract drift | Maintain shared schema tests; update fixtures alongside backend changes |
| Checkout metadata missing | Add migration + seed data early |
| Limited automated tests | Expand unit/widget/integration coverage |
| Printer optionality | Abstract ESC/POS usage to allow tree-shaking |

## 8. Next Steps

1. Implement caching layer + sync queue worker.  
2. Add checkout metadata table/migrations.  
3. Connect to production REST APIs (auth, DTO mapping, error handling).  
4. Expand automated testing (repositories, BLoCs, end-to-end order flow).  
5. Configure Sentry and CI/CD (DSN, release info, dependency audits, test gating).  
6. Profile performance and optimise once real data is wired.  
7. Introduce printer feature flags if not required for all deployments.

## 9. Reference Docs

- `OFFLINE_FIRST_GUIDE.md`  
- `STATUS.md`, `STATUS_UPDATED.md`, `STATUS_AND_NEXT_STEPS.md`  
- `FLUTTER_CONVERSION_GUIDE.md`  
- `FINAL_STATUS.md`  
- `MENU_EDITOR_WIZARD_IMPLEMENTATION.md`

---

The project is feature complete with a solid architecture. Focus remaining effort on data durability, backend integration, automation, and operational readiness to prepare for production launch. ✅