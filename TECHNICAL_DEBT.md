# OzPOS Flutter — Technical Debt

Structured list of refactoring, missing validations, architecture weaknesses, and performance concerns. Use with CURRENT_STATUS.md and ROADMAP.md.

---

## 1. Refactoring Needed

| Item | Location / Scope | Recommendation |
|------|------------------|----------------|
| **Routing** | `lib/core/navigation/app_router.dart` | PRD specifies GoRouter (Navigator 2). Current custom AppRouter works but does not provide declarative routes or deep linking. Consider migrating to GoRouter for consistency and future deep links. |
| **Local storage choice** | App-wide | PRD suggests Isar or Drift + Hive; codebase uses SQLite (sqflite) + SharedPreferences. Either document why (e.g. simplicity, desktop support) or plan migration if offline/sync requirements demand it. |
| **Duplicate / inconsistent models** | `lib/features/checkout/data/models/` vs `lib/features/orders/data/models/` | Order/order_item models exist in both checkout and orders; naming differs (e.g. order_item.dart vs order_item_model.dart). Unify or clearly define ownership (e.g. orders own Order entity; checkout uses DTOs). |
| **Deprecated baseUrl** | `lib/core/constants/app_constants.dart` | `baseUrl` is deprecated in favor of AppConfig.instance.baseUrl. Remove deprecated constant once all usages are migrated and document single source of truth. |
| **pos/ vs menu/** | `docs/FULL_ALIGNMENT_STATUS.md` | Doc references `lib/features/pos/` and menu_edit; codebase uses `lib/features/menu/` and MenuItemEditEntity. Update or remove stale doc to avoid confusion. |
| **Data source triad** | Multiple features | json_rules require Remote + Mock + Local. Users (and any other feature without local) either need a local datasource or the rule should be clarified (e.g. “Local when offline is required”). |

---

## 2. Missing Validations

| Item | Where | Recommendation |
|------|--------|----------------|
| **Input validation at API boundary** | Repositories / datasources | Client should validate payloads before send and handle server validation errors (422) with user-safe messages. Centralize in ApiClient or repository layer. |
| **Reservation overlap / business rules** | Reservations feature | Overlap warnings and smart table suggestions are in PRD/checklist; not verified in client. Implement or delegate to backend and display results. |
| **Modifier rules (min/max, required)** | Menu / checkout | Validate modifier selection (min/max, required) before add-to-cart; ensure server and client rules align. |
| **Loyalty redeem cap** | Checkout | Max redeem % and thresholds should come from server; client should not enforce arbitrary caps without API. |
| **Payment amount** | CheckoutBloc / ProcessPayment | Already basic checks (e.g. amount &gt; 0); ensure all tender totals match order total and handle rounding consistently. |

---

## 3. Architecture Weaknesses

| Item | Risk | Recommendation |
|------|------|-----------------|
| **No offline outbox** | Orders/table/reservation updates lost when offline; no retry or conflict handling. | Implement write-behind outbox with idempotency keys; sync when online; define conflict policy per entity type. |
| **No ETag / cache invalidation** | Menus and reservations may be stale; no standard way to invalidate. | Add ETag or updated_at read-through cache for menus and reservations; respect 304 from server. |
| **Payment processor abstraction** | Only SimulatedPaymentProcessor; no real Stripe path. | Introduce backend-backed implementation (e.g. ApiPaymentProcessor) and wire via DI; keep interface. |
| **Realtime** | No Laravel Echo/SSE/Pusher in client. | If order status or KDS updates must be real-time, add WebSocket or SSE client and connect to backend channels. |
| **Singleton BLoCs** | CartBloc, UserManagementBloc are app-wide. | Document lifecycle and disposal; ensure no leaks on logout (e.g. clear cart, cancel subscriptions). |
| **Error handling** | Mixed try/catch and Either; not every path maps to unified envelope. | Standardize on Either&lt;Failure, T&gt; in use cases and map failures to user-facing messages and retry options in presentation. |

---

## 4. Performance Concerns

| Item | Where | Recommendation |
|------|--------|----------------|
| **No performance budgets** | App-wide | Checklist requires 95th %ile &lt; 250 ms for UI actions and sync &lt; 1 s. Add profiling (e.g. Sentry traces, custom timers) and fail CI or release gate if exceeded. |
| **Large menu** | Menu grid, combo builder | Load test with 2k items and 300 add-ons; ensure virtualization (e.g. list view), pagination, or lazy load; verify server-side caching (e.g. Redis). |
| **BLoC rebuilds** | Presentation layer | Use Equatable and selective BlocBuilder/BlocSelector to avoid unnecessary rebuilds; audit large screens (checkout, menu editor, reports). |
| **Database** | database_helper, local datasources | No migration framework seen; add versioning and additive migrations for SQLite schema changes. |
| **Asset and bundle size** | Flutter build | Monitor web and mobile bundle size; tree-shake and lazy-load heavy features (e.g. docket designer, reports) if needed. |

---

## 5. Dead / Unused Code

| Item | Notes |
|------|--------|
| **FULL_ALIGNMENT_STATUS.md** | References non-existent `lib/features/pos/` and outdated menu_edit paths; either update to current structure or archive. |
| **Duplicate or legacy model files** | Some features have both `model/` and `models/` or inconsistent naming (e.g. order_item.dart vs order_item_model.dart). Grep for usages and consolidate. |
| **Unused endpoints in app_constants** | All listed endpoints may not have a corresponding implementation; audit and remove or mark as “reserved for backend.” |

---

## 6. Security & Compliance

| Item | Status | Recommendation |
|------|--------|-----------------|
| **Tokens** | Stored in secure storage; not logged. | Keep; add audit for any new token usage. |
| **HTTPS enforcement** | AppConfig enforces HTTPS in production. | Keep; ensure baseUrl is never overridden to http in prod. |
| **Certificate pinning** | Optional; config-driven. | Document when to enable; ensure pins are rotated via config. |
| **PII in logs / Sentry** | Sentry configured; PII minimization not fully audited. | Confirm Sentry PII disabled; scrub logs for tokens, PAN, and customer identifiers. |
| **CORS / CSRF** | Backend concern. | Client should only call approved origins; CSRF for web if backend requires it. |

---

## Priority Overview

| Priority | Focus | Typical action |
|----------|--------|-----------------|
| **P0** | Payments (Stripe), offline outbox, unified errors | Phase 1 roadmap. |
| **P1** | Reservation statuses, tests, Sentry tags, secrets doc | Phase 1. |
| **P2** | Split bill, loyalty API, order history, menu matrix, delivery adapter | Phase 2. |
| **P3** | GoRouter, storage alignment, model consolidation, performance budgets | Phase 3–4 and refactors. |

Use this document in sprint planning and architecture reviews; update as items are resolved or new debt is identified.
