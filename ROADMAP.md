# OzPOS Flutter — Roadmap

Phased plan aligned with PRD, LIVING_CHECKLIST, and CURRENT_STATUS. Prioritize critical gaps first, then feature completion, then enhancements and scale.

---

## Phase 1: Critical Fixes & Foundation

**Goal:** Unblock production readiness and align with golden rules.

| # | Task | Owner / Notes |
|---|------|-------------------------------|
| 1.1 | **Stripe Connect (client side)** — Replace SimulatedPaymentProcessor with backend-driven flow: client calls backend for payment intents/fees; display results only; no client-side fee math. | Backend must expose endpoints; client implements PaymentProcessor that calls API. |
| 1.2 | **Unified error envelope** — Standardize API error handling: map 422/400/402/502/500 to user-safe messages, retry affordances, actionable codes. | Core/network or per-repository. |
| 1.3 | **Secrets & config** — Confirm no secrets in repo; document all env vars (e.g. baseUrl, Sentry DSN) in README and example.env. | DevOps + dev. |
| 1.4 | **Sentry tags** — Set vendor_id, user_role, order_id, integration_service where applicable (checkout, orders, auth). | Core/services + feature blocs. |
| 1.5 | **Reservation statuses** — Add Early, Late, No-show, Completed to ReservationStatus enum and any server contract; implement Late timer if required by PRD. | Reservations feature + backend. |
| 1.6 | **Tests** — Introduce minimal test suite: `flutter analyze` clean, `flutter test` for critical use cases (e.g. auth, checkout flow, cart). Add golden tests for key widgets if required by checklist. | QA + dev. |

**Exit criteria:** Payments server-driven (or clearly stubbed with backend contract), errors standardized, no secrets in code, reservation statuses complete, tests green.

---

## Phase 2: Feature Completion

**Goal:** Bring partial features to “Definition of Done” per LIVING_CHECKLIST.

| # | Task | Notes |
|---|------|--------|
| 2.1 | **Offline & sync** — Read-through cache with ETag/updated_at for menus and reservations; write-behind outbox for orders, table ops, reservations with idempotency keys and exponential backoff. Define conflict policy (orders: state machine; tables/reservations: server timestamp; menu: LWW + audit). | Large effort; consider starting with orders only. |
| 2.2 | **Split bill** — Complete by person/item/equal/custom; drag-assign; per-split payment; reconcile remaining due (align tables screen and checkout). | Checkout + tables. |
| 2.3 | **Loyalty** — Implement loyalty account/balance and earn preview via API; surface in checkout and customer display; thresholds and max redeem % from server. | Checkout + customer_display + backend. |
| 2.4 | **Order history** — Unified order cards with source badges (UberEats, DoorDash, etc.); tabs Active/Completed/Cancelled; third-party read-only where applicable. | Orders feature. |
| 2.5 | **Menu editing** — Pricing matrix (per-item/per-size overrides, inheritance); reusable add-on sets (required/optional, min/max, included N, per-option price); bulk availability and duplicate; POS/Online visibility toggles. | Menu + addons. |
| 2.6 | **Delivery / dispatch** — Orders panel tabs (Ready/In-Progress/Completed/Problem); driver panel (status, last seen/live, KPIs); third-party adapter (e.g. UberDirect v1) behind feature flag; geofencing/ETAs with mocked positions for verification. | Delivery feature + backend. |
| 2.7 | **Reservations** — Overlap warnings and smart table suggestions; move/merge with irreversible-action warnings; reconciliation prompts after reconnect. | Reservations + tables. |
| 2.8 | **Reporting** — KPI snapshot, trends, funnel, speed gauges within perf budget; export PDF/XLS with correct data and date/vendor in file names. | Reports feature + backend. |
| 2.9 | **Settings** — Read-only Stripe Connect onboarding/status in Settings. | Settings + backend API. |
| 2.10 | **KDS** — Dedicated KDS/ticket lanes UI if required by PRD (BOH); link to docket designer templates. | New or extend docket/orders. |

**Exit criteria:** All PRD v1 features either implemented or explicitly scoped out; checklist DoD satisfied for touched areas.

---

## Phase 3: Enhancements

**Goal:** Quality, observability, and UX.

| # | Task | Notes |
|---|------|--------|
| 3.1 | **Telemetry events** — screen_view, add_to_cart, redeem_points, split_pay, dispatch_create, reservation_create. | Sentry or analytics. |
| 3.2 | **Accessibility** — Labels for critical controls; keyboard/focus check (Web/Windows). | All feature screens. |
| 3.3 | **Simulated offline tests** — Queued orders, print while offline, reconciliation banners on reconnect. | Test suite. |
| 3.4 | **Rollback plan / feature flags** — Document per-feature rollback; use feature flags for risky or partner integrations. | Ops + backend. |
| 3.5 | **OpenAPI / Postman** — Backend: keep OpenAPI updated and Postman collection regenerated (CI). | Backend repo. |

---

## Phase 4: Optimization & Scaling

**Goal:** Performance budgets and scale.

| # | Task | Notes |
|---|------|--------|
| 4.1 | **Performance budgets** — 95th percentile UI action &lt; 250 ms; sync commits &lt; 1 s typical. Measure and add to CI or release checklist. | Perf tooling. |
| 4.2 | **Menu load test** — 2k items, 300 add-ons; verify Redis caching on server and client responsiveness. | Backend + client. |
| 4.3 | **Security gates** — Rate limits, CORS, CSRF (web), Sanctum checks; no PII in logs; Sentry PII disabled. | Backend + client config. |
| 4.4 | **Release readiness** — Version bump + changelog; feature flags staged; migrations applied in staging; rollback instructions validated; pilot venue checklist (printers, KDS, delivery). | Ops. |

---

## Summary Table

| Phase | Focus | Typical duration (estimate) |
|-------|--------|-----------------------------|
| **1** | Critical fixes (Stripe, errors, secrets, Sentry, reservation statuses, tests) | 2–3 sprints |
| **2** | Feature completion (offline, split bill, loyalty, orders, menu, delivery, reservations, reports, settings, KDS) | 6–8 sprints |
| **3** | Enhancements (telemetry, a11y, offline tests, feature flags) | 2–3 sprints |
| **4** | Optimization & scaling (perf, load test, security, release playbook) | 1–2 sprints |

Adjust scope and order based on business priority; Phase 1 should be non-negotiable for any production launch.
