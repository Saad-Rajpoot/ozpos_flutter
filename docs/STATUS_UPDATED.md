# OZPOS Flutter – Status Update (November 2025)

## ✅ Foundations in Place

- **Architecture** – Clean architecture (BLoC + use cases + repositories) across all feature modules. Dependency injection selects mock JSON data sources in development and REST data sources in production.
- **Feature coverage** – Dashboard, menu, checkout, addons, combos, orders, tables, delivery, reservations, reports, settings, printing/docket designer, and customer display all render with mock data and respond to user actions.
- **Checkout persistence** – Checkout flow saves orders to SQLite; split/tip/loyalty/voucher logic runs through `CheckoutBloc`.
- **Design system** – Shared gradients, typography, spacing, breakpoints, dark/light themes, and reusable UI components.
- **Observability** – Sentry integration, connectivity detection, `ApiClient` retry interceptor, and global navigation service.

## 📊 Current Metrics

| Metric | Value |
| ------ | ----- |
| Dart files | 380 |
| Dart LOC | 56,899 |
| Feature modules | 11 + shared core |
| Registered BLoCs | 20+ |
| Runtime dependencies | 24 (no Firebase SDKs) |
| Mock datasets | 40+ JSON fixtures |
| SQLite tables | 10 |

## 🎯 Working Flows

- Navigate via dashboard tiles to every feature.  
- Browse menu, filter categories, launch the menu wizard, manage cart with `CartBloc`.  
- Run the checkout flow (tips, split payments, vouchers, loyalty, change calculation) and persist orders locally.  
- Review orders, tables, delivery, reservations, and reports screens populated by mock data sources.  
- Access settings, printing management, docket designer, addon management, combo editor, and customer display routes—all wired through `AppRouter`.

## 🧭 Outstanding Gaps

1. **Offline read caching** – Repositories still return `NetworkFailure` when offline; implement caching (SQLite or alternative) for menu/addons/combos/orders data.  
2. **Sync queue worker** – The `sync_queue` table is provisioned but unused; add a service to record and replay pending operations when connectivity returns.  
3. **Checkout metadata table** – Add the missing table/migration that `CheckoutLocalDataSource` expects.  
4. **API integration** – Finalize REST endpoints, DTO mapping, authentication, and error handling; keep mock JSON in sync with backend contracts.  
5. **Automated testing** – Build unit and widget tests for repositories, BLoCs, and core user journeys (menu → checkout).  
6. **Performance** – Large fixture loads happen synchronously; evaluate pagination/lazy loading when connecting to production APIs.

## 🚀 Next Priorities

| Task | Owner | Notes |
| ---- | ----- | ----- |
| Implement caching layer | Eng | Hydrate SQLite tables and read from cache when offline. |
| Build sync background service | Eng | Persist queue entries, drain when network is restored. |
| Wire production APIs | Eng/Backend | Configure `ApiClient`, add contract tests, handle auth/refresh flows. |
| Extend database schema | Eng | Add checkout metadata table and any supporting seed data. |
| Expand automated tests | Eng/QA | Unit tests for repositories/use cases, widget tests for menu/checkout, integration tests for order lifecycle. |
| Configure Sentry & CI | DevOps | Inject DSN/env/release via `--dart-define`, add dependency audit to CI. |

## 🛠 Commands

```bash
flutter pub get
flutter run                          # mock data
flutter run --dart-define=APP_ENV=production
flutter build apk --dart-define=APP_ENV=production
```

## 📚 See Also

- `STATUS.md` – long-form status & roadmap.  
- `OFFLINE_FIRST_GUIDE.md` – data/persistence plan.  
- `FLUTTER_CONVERSION_GUIDE.md` – architecture breakdown.  
- `FINAL_STATUS.md` – comprehensive feature summary.

---

The build is feature complete with mock-driven data. Focus now shifts to robust offline caching, sync, API integration, and automated tests ahead of production launch. 💼
