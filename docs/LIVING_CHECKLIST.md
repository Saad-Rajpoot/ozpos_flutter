# LIVING_CHECKLIST.md — OzPOS Flutter POS (Living Check)

> Keep this file up to date. Every PR touching POS, API, or payments must tick relevant boxes.

## 0) Objectives (v1)
- [ ] Cross-platform Flutter app (Web, iOS, Android, Windows) with >90% shared code.
- [ ] Plugin-light implementation; only well-maintained, cross-platform packages.
- [ ] **Clean Architecture** with Domain/Data/Presentation layers.
- [ ] **BLoC Pattern** for state management with Navigator 2.0 + AppRouter.
- [ ] Offline read-through cache + write-behind outbox (orders, tables, reservations, drivers, menu deltas).
- [ ] Payments via server-driven Stripe Connect; **no client-side fee math**.
- [ ] Unified error envelope, Sentry parity, and redaction rules.
- [ ] Full FormRequest validation + OpenAPI annotations for new/changed endpoints.
- [ ] **Laravel Echo/SSE** realtime updates for order status, KDS lanes, dispatch.

## 1) Golden Rules (blockers if violated)
- [ ] No secrets/keys in client or repo; all secrets from `.env` (server) or platform keychains (client).
- [ ] **Device-scoped Sanctum tokens** stored with key name 'token' in SharedPreferences; never logged.
- [ ] **BLoC Pattern** used consistently across all features.
- [ ] **Clean Architecture** layers respected (Domain/Data/Presentation).
- [ ] **AppRouter** used for all navigation (centralized route management).
- [ ] **Freezed + JsonSerializable** used for all data models.
- [ ] **SQLite + Hive** used for local storage.
- [ ] **Dio with interceptors** used for all HTTP requests.
- [ ] **GetIt** used for dependency injection.
- [ ] Respect server state machines (orders, dispatch, reservations). Client NEVER force-transitions.
- [ ] Server is source of truth for pricing/fees/taxes/loyalty rules.
- [ ] Additive DB migrations only; no destructive changes without migration plan & rollback section.
- [ ] Security headers middleware enabled in API responses; do not disable CSP/HSTS/XFO in prod.
- [ ] **CSRF for Web** and **CORS** restrictions to approved origins.
- [ ] All user-facing errors mapped to standardized envelope with actionable messages.

## 2) Pre-Commit / Pre-PR Checklist
- [ ] PHP: `pint` (PSR-12) clean, Pest tests green, PHPStan max level passing.
- [ ] Flutter: `flutter analyze` clean, `flutter test` green, golden tests updated with review.
- [ ] **BLoC classes** properly tested and documented.
- [ ] **Freezed models** with proper equality and toString implementations.
- [ ] **Dio interceptors** tested for auth, retry, and ETag handling.
- [ ] OpenAPI updated and validated; Postman collection regenerated.
- [ ] New env vars documented in README and `example.env` (server only).
- [ ] Sentry tags (`vendor_id`, `user_role`, `order_id`, `integration_service`) set where applicable.
- [ ] Accessibility: labels for critical controls; keyboard/focus check (Web/Windows).

## 3) Feature Definition of Done (DoD)
- [ ] User stories & acceptance criteria in PR description.
- [ ] Backend endpoints: FormRequests + policy/permission checks + OpenAPI annotations.
- [ ] Client: error handling (422/400/402/502/500) with retry affordances.
- [ ] Tests: unit + integration (backend), widget/golden/integration (client).
- [ ] Telemetry events added: `screen_view`, `add_to_cart`, `redeem_points`, `split_pay`, `dispatch_create`, `reservation_create`.
- [ ] Rollback plan or feature flag documented.

## 4) Offline & Sync
- [ ] **ETags/updated_at watermarks** read-through for menus/reservations.
- [ ] **Idempotency keys** used for all write-behind outbox operations.
- [ ] Outbox queue with idempotency keys + exponential backoff.
- [ ] **Conflict policy** implemented: orders (strict state machine), tables/reservations (server timestamp wins), menu (LWW + audit).
- [ ] **Laravel Echo/SSE** channels for realtime updates (order status, KDS lanes, dispatch).
- [ ] Simulated offline tests: queued orders, print while offline, reconciliation banners on reconnect.

## 5) Printing
- [ ] **ESC/POS LAN socket** pipeline works (KOT + receipt).
- [ ] **Platform channel abstraction** for BLE/USB printers.
- [ ] OS print fallback (AirPrint/Windows) verified.
- [ ] Category→printer routing respected; "Test Print" works.
- [ ] **Concurrent KOT printing** load tested.
- [ ] No sensitive data printed (card PAN/CSC).

## 6) Payments (Stripe Connect)
- [ ] Client delegates intents/fees to backend; displays results only.
- [ ] Refunds/voids go through backend; ledger entries verified.
- [ ] Webhooks captured with retry/DLQ; test with CLI/NGROK.
- [ ] Connect onboarding/status surfaced read-only in app Settings.

## 7) Loyalty & Promotions
- [ ] **Customer lookup and points balance** display.
- [ ] **Earn/redeem preview** with thresholds and max redeem %.
- [ ] **Partial redemption** and conflict resolution.
- [ ] **Auto-nudges** when points available.
- [ ] **Voucher/QR promos** with "best value" conflict resolution.

## 8) Multi-Source Order History
- [ ] **Third-party order integration** (UberEats, DoorDash, Menulog, Website, App, QR).
- [ ] **Source badges** and timestamps with payment status.
- [ ] **Read-only status sync** for third-party orders.
- [ ] **Adapter pattern** for partner APIs with webhook/state sync.
- [ ] Tabs: Active/Completed/Cancelled; compact vs expanded.

## 9) QR/Camera Integration
- [ ] **camera + barcode_scan2** for QR functionality.
- [ ] **MLKit web interop** for web QR scanning.
- [ ] **QR table linkage** and handoff to KDS.

## 10) Reservations & Tables
- [ ] **Status management**: Pending/Confirmed/Seated/Early/Late(+timer)/No-show/Cancelled/Completed.
- [ ] **Smart table suggestions** and overlap warnings.
- [ ] **Fixed-menu attachment** and notes.
- [ ] Move/Merge flows preview + irreversible warnings.
- [ ] **Table integration** with conflict prompts.
- [ ] Reconciliation prompts when conflicts occur after reconnect.

## 11) Delivery & Dispatch
- [ ] Orders panel tabs (Ready/In-Progress/Completed/Problem).
- [ ] **Driver panel**: status, assigned orders, live/last location, KPIs.
- [ ] **Live Map** with pins/filters/ETAs and geofencing.
- [ ] **Third-party dispatch adapters** (UberDirect/Drive) via adapter + webhook/state sync.
- [ ] **Driver location tracking** with mocked positions.
- [ ] **ETAs verified** with geofencing and live updates.

## 12) Menu Editing & Pricing Matrix
- [ ] **Pricing Matrix**: per-item/per-size overrides with inheritance precedence documented.
- [ ] **Reusable add-on sets** (required/optional, min/max, included N, per-option price).
- [ ] **Add/Edit Item Wizard**: Item → Sizes → Add-ons → Pricing & Availability → Review.
- [ ] **Bulk operations**: availability toggles, duplicate, reorder functionality.
- [ ] **POS/Online visibility** toggles respected across caches.
- [ ] **Menu dashboard**: category rail, inline price edits, "Save All" functionality.

## 13) Reporting & Ops
- [ ] **KPIs**: Sales, AOV, Orders, Turnover time, Gross Margin %, Loyalty activity.
- [ ] **Ops health funnel**: Placed→Kitchen→Served→Paid, speed gauge, discounts effect, payments mix.
- [ ] **Trends**: hourly sales, category mix, top/under-performers, staff, table utilization.
- [ ] **Export (PDF/XLS)** returns correct data + file names with date/vendor.
- [ ] **Links into advanced web BI** dashboards.

## 14) Performance Budgets
- [ ] **>60 FPS UI** maintained across all screens.
- [ ] 95th percentile UI action < 250ms local; sync commits < 1s typical.
- [ ] **Menu load tested** with 2k items, 300 add-ons; Redis caching on server.
- [ ] **Concurrent operations** tested (KOT printing, sync, realtime updates).

## 15) Security Gates
- [ ] Rate limits configured for endpoints touched.
- [ ] No PII in logs/analytics; Sentry PII disabled.
- [ ] CORS rules restricted to approved origins.
- [ ] **CSRF (web) and Sanctum token checks** confirmed.
- [ ] **Audit trails** for payments, dispatch, menu edits, reservations.
- [ ] **Device-scoped tokens** and secure storage verified.

## 16) Release Readiness
- [ ] Version bump + changelog.
- [ ] Feature flags staged; migrations applied in staging.
- [ ] Rollback instructions validated.
- [ ] **Pilot venue checklist** prepared (printers, KDS, delivery, QR codes).
- [ ] **Clean Architecture** compliance verified.
- [ ] **BLoC classes** properly documented and tested.

## 17) Rollback Playbook (per feature)
- [ ] Disable feature flag or route traffic away (server).
- [ ] Revert app feature toggle (remote config where applicable).
- [ ] DB rollback step (if non-additive migration used).
- [ ] **BLoC state** reset and cache cleared.
- [ ] Post-mortem issue created with Sentry links and logs.
