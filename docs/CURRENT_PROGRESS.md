# OZPOS Flutter – Current Progress

## ✅ Shipped This Session

- **Architecture hardening** – All feature modules now use BLoC + clean architecture, driven by dependency injection (`lib/core/di/injection_container.dart`). Menu, checkout, addons, combos, orders, tables, delivery, reservations, reports, settings, printing, docket designer, and customer-display flows spin up correctly through `AppRouter`.
- **Environment-driven data sources** – Development mode loads realistic JSON fixtures from `assets/**`; production mode swaps to REST repositories backed by the shared `ApiClient`.
- **Checkout persistence** – Checkout writes orders to SQLite via `CheckoutLocalDataSource`. (Metadata table support still pending.)
- **SQLite schema** – `DatabaseHelper` provisions menu/items/modifiers/tables/reservations/printers/cart/sync tables, ready for full offline caching.
- **Theming & layout** – Shared gradient palette, responsive breakpoints, typography, shadows, and spacing tokens centralised in `lib/core/theme` and `lib/core/constants`.
- **Observability** – Sentry bootstrap, connectivity monitoring, and retry-aware HTTP pipeline integrated in `main.dart`.

## 🎯 What Works Right Now

| Area | Status | Notes |
| ---- | ------ | ----- |
| Dashboard navigation | ✅ | Gradient tiles route to every feature module. |
| Menu browsing & editor | ✅ | Mock data via `MenuMockDataSource`; menu wizard fully interactive with `MenuEditBloc`. |
| Cart & checkout | ✅ | `CartBloc` persists across navigation; `CheckoutBloc` handles tips, split payments, vouchers, and saves orders locally. |
| Addons & combos | ✅ | CRUD operations backed by mock payloads; BLoCs wired through DI. |
| Orders, tables, reservations, delivery, reports, settings, printing, customer display | ✅ | Screens load fixtures, respond to refresh events, and demonstrate full UI flows. |
| Error tracking | ✅ | BLoC observer + Sentry integration capture runtime issues. |

## 🧭 Live Demo Checklist

1. `flutter run` (default is development/mock mode).  
2. Dashboard → any tile (e.g. Menu).  
3. Menu → add items to cart, filter categories, launch menu wizard.  
4. Checkout → test payment flows (cash keypad, tips, split payments, vouchers, loyalty).  
5. Navigate through Orders, Tables, Delivery, Reservations, Reports, Settings, Printing, Addon Management, Combo Editor, Customer Display to verify BLoC initialisation and mock data rendering.  
6. Inspect console output for connectivity/network logs and Sentry breadcrumbs (when DSN enabled).

## 📊 Updated Metrics

| Metric | Value |
| ------ | ----- |
| Dart files | 380 |
| Dart LOC | 56,899 |
| Feature modules | 11 + shared core |
| Registered BLoCs | 20+ |
| Mock JSON payloads | 40+ |
| SQLite tables | 10 |
| Runtime dependencies | 18 |

## 🪫 Known Gaps / Risks

1. **Offline read behaviour** – Repositories return `NetworkFailure` when offline. Need caching (SQLite or alternative storage) for menu/addon/combos/orders data.  
2. **Sync queue unused** – Table exists but no background service populates or flushes it.  
3. **Checkout metadata** – `CheckoutLocalDataSource` expects a `metadata` table that is not yet created by `DatabaseHelper`.  
4. **API parity** – Mock JSON shape must stay aligned with real endpoints; add contract tests once REST integration lands.  
5. **Automated testing** – Minimal unit/widget/test coverage; high risk of regressions without additional suites.  
6. **Performance** – Large fixture loads still happen synchronously; evaluate pagination or lazy loading for production data.

## 📌 Next Focus

| Task | Priority | Notes |
| ---- | -------- | ----- |
| Implement SQLite/SQLite-backed caching for read flows | 🔴 High | Seed tables from mock JSON or REST responses; expose cached repositories when offline. |
| Build sync queue worker | 🔴 High | Persist write operations, replay on connectivity regain. |
| Finalise REST integration | 🔴 High | Wire production repositories to API endpoints, add DTO → entity mapping tests. |
| Checkout metadata migration | 🟠 Medium | Add table/migration + seed data. |
| Test suite expansion | 🟠 Medium | Unit tests for repositories/use cases, widget tests for dashboard/menu/checkout, integration test for order lifecycle. |
| Performance audit | 🟢 Low | Profile heavy screens, add caching for images/assets. |

## 🔧 Quick Commands

```bash
flutter pub get
flutter run                     # dev/mock data
flutter run --dart-define=APP_ENV=production
flutter build apk --dart-define=APP_ENV=production
```

## 📚 Related Docs

- `STATUS.md` – high-level status & roadmap.  
- `OFFLINE_FIRST_GUIDE.md` – detailed data/persistence plan.  
- `FLUTTER_CONVERSION_GUIDE.md` – architecture overview.  
- `MENU_EDITOR_WIZARD_IMPLEMENTATION.md` – menu wizard specifics.

---

The Flutter implementation now mirrors the original product surface with mock-backed data. Priorities shift to production APIs, resilient offline behaviour, and automated tests to keep the codebase healthy. 🚀
