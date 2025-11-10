# OZPOS Flutter – Work Alignment & Roadmap Plan (WARP)

## 1. Current Foundation

- **Architecture**: Clean architecture with BLoC presentation, use cases, repositories, and injection via `GetIt`.  
- **Data sources**: Development mode loads JSON fixtures; production mode targets REST APIs.  
- **Storage**: SQLite schema created (menu, modifiers, orders, tables, reservations, printers, cart, sync queue). Checkout writes to SQLite today.  
- **Observability**: Sentry bootstrap, connectivity monitoring, retry interceptor in `ApiClient`.  
- **Features**: Dashboard, menu, checkout, addons, combos, orders, tables, delivery, reservations, reports, settings, printing, docket designer, and customer display all run with mock data.

## 2. Near-Term Goals (0–4 Weeks)

| Goal | Description | Owner |
| ---- | ----------- | ----- |
| Offline caching | Hydrate SQLite tables from assets/REST responses; read from cache when offline. | Engineering |
| Sync queue worker | Persist offline mutations to `sync_queue`, replay when connectivity returns. | Engineering |
| REST integration | Finalize API endpoints, DTOs, authentication, and error handling; keep fixtures in sync with contracts. | Backend + Engineering |
| Checkout metadata | Add missing metadata table/migrations in `DatabaseHelper`. | Engineering |
| Automated tests | Unit tests for repositories/use cases, widget tests for menu/checkout, integration test for order flow. | Engineering/QA |
| Sentry & CI setup | Inject DSN/env/release via `--dart-define`, add dependency audits and build caching. | DevOps |

## 3. Mid-Term Goals (4–8 Weeks)

- Optimise performance once real data is connected (pagination, lazy loading).  
- Implement printer feature flags to trim bundle size when ESC/POS is not required.  
- Harden error handling and retry logic using real backend responses.  
- Add analytics or observability hooks as needed (without Firebase dependency unless reintroduced).  
- Prepare release builds for pilot environments (QA/staging).

## 4. Risks & Mitigations

| Risk | Mitigation |
| ---- | ---------- |
| Offline experience incomplete | Deliver caching + sync queue before connecting to live endpoints. |
| API contract drift | Maintain shared schema docs/tests; update fixtures alongside backend changes. |
| Checkout metadata missing | Add migration early to avoid runtime failures. |
| Printer-specific code bloats bundle | Guard ESC/POS usage behind service abstraction/feature flag. |
| Limited test coverage | Prioritise test writing after caching/REST work is in place. |

## 5. Success Criteria

- App runs seamlessly in offline, intermittent, and online modes.  
- REST endpoints supply real data with proper error handling and retries.  
- Automated test suite covers core flows (menu → checkout, sync queue replay).  
- Sentry captures actionable telemetry; CI enforces linting, tests, and dependency audits.  
- Feature flags or configuration options handle optional capabilities (printers, analytics).

## 6. Key References

- `OFFLINE_FIRST_GUIDE.md` – caching & sync strategy  
- `STATUS.md` / `STATUS_UPDATED.md` – status snapshots  
- `FLUTTER_CONVERSION_GUIDE.md` – architecture details  
- `FINAL_STATUS.md` – feature-by-feature summary

---

This roadmap keeps the project focused on production readiness: offline durability, real data integration, observability, and automation. 🚀