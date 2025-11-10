# Status & Next Steps (November 2025)

## ✅ Current Status

- Build compiles cleanly for mobile, web, and desktop.  
- Menu Item Wizard (`MenuItemWizardScreen`) is integrated and aligned with the current `MenuItemEditEntity`/BLoC implementation in `lib/features/menu`.  
- Dashboard, menu, checkout, addons, combos, orders, tables, delivery, reservations, reports, settings, printing, docket designer, and customer display routes are live with mock data.  
- SQLite schema is provisioned (menu, modifiers, orders, tables, reservations, printers, cart, sync queue). Checkout writes to SQLite; other repositories will leverage caching next.  
- No Firebase dependencies remain; production mode targets REST endpoints via `ApiClient`.

## ⚠️ Active Risks

1. **Offline read behaviour** – Repositories still return `NetworkFailure` when offline.  
2. **Sync queue idle** – `sync_queue` table unused until a background worker is added.  
3. **Checkout metadata** – Add the missing `metadata` table/migration to `DatabaseHelper`.  
4. **API parity** – Ensure mock JSON matches backend contracts; add DTO/contract tests when REST integration lands.  
5. **Automated testing** – Minimal coverage; add unit/widget/integration suites to protect key flows.  
6. **Printer optionality** – ESC/POS packages increase bundle size; consider feature flags for builds without printers.

## 🚀 Next Steps

| Priority | Task | Owner | Notes |
| -------- | ---- | ----- | ----- |
| 🔴 | Implement repository caching | Engineering | Hydrate SQLite tables from assets or API responses; read from cache when offline. |
| 🔴 | Build sync queue worker | Engineering | Write pending operations to `sync_queue` and replay when connectivity returns. |
| 🔴 | Wire production API endpoints | Engineering/Backend | Configure `ApiClient`, add DTO mapping tests, handle auth/refresh flows. |
| 🟠 | Extend database schema | Engineering | Add checkout metadata table + seed data. |
| 🟠 | Expand automated tests | Engineering/QA | Repositories, BLoCs, and core journeys (menu → checkout). |
| 🟢 | Configure Sentry + CI pipelines | DevOps | Inject DSN/env/release via `--dart-define`, run dependency audits, add build cache. |

## 🧰 Quick Commands

```bash
flutter pub get
flutter run                          # development (mock data)
flutter run --dart-define=APP_ENV=production
flutter build apk --dart-define=APP_ENV=production
```

## 📚 Reference

- `OFFLINE_FIRST_GUIDE.md` – Offline/caching roadmap  
- `STATUS.md` & `STATUS_UPDATED.md` – High-level status + roadmap  
- `FINAL_STATUS.md` – Feature-by-feature summary  
- `FLUTTER_CONVERSION_GUIDE.md` – Architecture overview

---

Focus shifts from UI completion to data durability (caching + sync), backend integration, and automated validation. Once those are complete, the build will be production-ready. ✅
