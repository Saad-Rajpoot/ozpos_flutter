# OZPOS Flutter – Implementation Status (November 2025)

## 🌟 Overview

The Flutter port now mirrors the full OZPOS product surface across mobile, web, and desktop. All feature modules are implemented with BLoC-driven presentation, environment-aware data sources, and a shared design system. Development mode uses rich mock JSON fixtures, while production mode swaps to REST repositories. SQLite schema support is in place for true offline behaviour, with checkout already persisting orders locally.

## ✅ Feature Coverage

| Area | Status | Notes |
| ---- | ------ | ----- |
| Dashboard | ✅ | Gradient navigation tiles route to every module via `AppRouter`. |
| Menu browse & editor | ✅ | Menu grid, filtering, and the 5-step menu wizard run on `MenuBloc` + `MenuEditBloc`. |
| Cart & checkout | ✅ | `CartBloc` persists globally; checkout flow handles tips, loyalty, vouchers, split payments, and writes orders to SQLite. |
| Addons & combos | ✅ | CRUD workflows powered by mock data sources and DI-provided BLoCs. |
| Orders, tables, reservations, delivery | ✅ | Screens load fixture data, support filtering/refresh, and demonstrate table/floor views. |
| Reports & settings | ✅ | Analytics cards, charts, and settings categories sourced from JSON fixtures. |
| Printing & docket designer | ✅ | ESC/POS integration stubs plus a visual docket editor UI. |
| Customer display | ✅ | Launches as a modal route with its own BLoC. |
| Observability | ✅ | Sentry integration, BLoC observer logging, connectivity monitoring, retryable HTTP client. |

> All features run with mock data today; production mode is ready to consume REST endpoints once the backend is available.

## 🧱 Architecture Snapshot

- **Presentation** – `flutter_bloc` across every feature module; shared base classes in `lib/core/base`.  
- **Domain** – Use cases expose `dartz` `Either` results; repositories map between data models and domain entities.  
- **Data layer** – DI registers either mock JSON data sources (development) or `Dio`-backed remote data sources (production).  
- **Storage** – `DatabaseHelper` creates tables for menu, modifiers, orders, tables, reservations, printers, cart items, and a `sync_queue`. Checkout already writes to SQLite; other repositories will leverage caching in upcoming work.  
- **Navigation** – Centralized route generation in `AppRouter`; `NavigationService` enables context-free navigation and global snackbars.  
- **Design system** – Light/dark themes, gradients, typography, spacing, and responsive breakpoints consolidated in `lib/core/theme` and `lib/core/constants`.

## 📊 Key Metrics

| Metric | Value |
| ------ | ----- |
| Dart files | 380 |
| Dart LOC | 56,899 |
| Feature modules | 11 + shared core |
| BLoCs registered | 20+ |
| Mock JSON fixtures | 40+ |
| Runtime dependencies | 24 (no Firebase SDKs) |
| SQLite tables | 10 |

## 🧭 Current Gaps & Risks

1. **Offline read caching** – Repositories currently return `NetworkFailure` when offline. Caching via SQLite (or alternative storage) is the top priority.  
2. **Sync queue service** – The `sync_queue` table exists but no background worker persists or flushes operations yet.  
3. **Checkout metadata table** – `CheckoutLocalDataSource` expects a `metadata` table that still needs to be added to `DatabaseHelper`.  
4. **API contract parity** – Ensure mock JSON stays aligned with the REST API; add contract tests when production endpoints go live.  
5. **Automated testing** – Minimal unit/widget/integration coverage; add tests for core flows and repositories.  
6. **Printing rollout** – ESC/POS libraries add size; wrap printer access behind services so non-printer builds can tree-shake unused code.  
7. **Performance** – Large fixture loads happen synchronously; evaluate pagination or lazy loading for production datasets.

## 🚀 Next Steps

| Task | Owner | Notes |
| ---- | ----- | ----- |
| Implement repository caching (menu/addons/combos/orders) | Engineering | Hydrate SQLite tables from assets or API responses; fall back to cached data when offline. |
| Build sync worker | Engineering | Use connectivity callbacks to write to and drain `sync_queue`. |
| Finalise REST integration | Backend + mobile | Configure `ApiClient` endpoints, DTOs, token refresh, and error handling; add contract tests. |
| Add checkout metadata table & migrations | Engineering | Extend `DatabaseHelper` and seed baseline entries. |
| Expand automated tests | QA/Engineering | Unit tests for repositories/use cases, widget tests for dashboard/menu/checkout, integration test for order lifecycle. |
| Configure Sentry & CI | DevOps | Inject DSN, environment, and release version via `--dart-define`; add dependency audit (`flutter pub outdated`). |

## 🧰 Run & Build

```bash
flutter pub get
flutter run                          # development (mock data)
flutter run --dart-define=APP_ENV=production
flutter build apk --dart-define=APP_ENV=production
```

Ensure production builds supply API base URLs and Sentry configuration through `--dart-define` or environment variables.

## 📚 Reference Docs

- `STATUS.md` – live status & roadmap  
- `OFFLINE_FIRST_GUIDE.md` – data/persistence deep dive  
- `FLUTTER_CONVERSION_GUIDE.md` – architecture overview  
- `MENU_EDITOR_WIZARD_IMPLEMENTATION.md` – wizard details

---

The Flutter port is feature complete with mock-driven data and production-ready architecture. Focus now shifts to real backend integration, offline caching, sync reliability, and automated validation to prepare for launch. 💡
