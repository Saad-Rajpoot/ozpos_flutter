# LIVING_CHECKLIST.md — OzPOS Flutter POS (Living Check)

> Keep this file up to date. Every PR touching POS, API, or payments must tick relevant boxes.

## 0) Objectives (v1)
- [ ] Cross-platform Flutter app (Web, iOS, Android, Windows) with >90% shared code.
- [ ] Plugin-light implementation; only well-maintained, cross-platform packages.
- [ ] Offline read-through cache + write-behind outbox (orders, tables, reservations, drivers, menu deltas).
- [ ] Payments via server-driven Stripe Connect; **no client-side fee math**.
- [ ] Unified error envelope, Sentry parity, and redaction rules.
- [ ] Full FormRequest validation + OpenAPI annotations for new/changed endpoints.

## 1) Golden Rules (blockers if violated)
- [ ] No secrets/keys in client or repo; all secrets from `.env` (server) or platform keychains (client).
- [ ] Sanctum tokens stored in secure storage; never logged.
- [ ] Respect server state machines (orders, dispatch, reservations). Client NEVER force-transitions.
- [ ] Server is source of truth for pricing/fees/taxes/loyalty rules.
- [ ] Additive DB migrations only; no destructive changes without migration plan & rollback section.
- [ ] Security headers middleware enabled in API responses; do not disable CSP/HSTS/XFO in prod.
- [ ] All user-facing errors mapped to standardized envelope with actionable messages.

## 2) Pre-Commit / Pre-PR Checklist
- [ ] PHP: `pint` (PSR-12) clean, Pest tests green, PHPStan max level passing.
- [ ] Flutter: `flutter analyze` clean, `flutter test` green, golden tests updated with review.
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
- [ ] ETag/watermark read-through for menus/reservations.
- [ ] Outbox queue with idempotency keys + exponential backoff.
- [ ] Conflict policy implemented: orders (strict state machine), tables/reservations (server timestamp wins), menu (LWW + audit).
- [ ] Simulated offline tests: queued orders, print while offline, reconciliation banners on reconnect.

## 5) Printing
- [ ] LAN ESC/POS pipeline works (KOT + receipt).
- [ ] OS print fallback (AirPrint/Windows) verified.
- [ ] Category→printer routing respected; “Test Print” works.
- [ ] No sensitive data printed (card PAN/CSC).

## 6) Payments (Stripe Connect)
- [ ] Client delegates intents/fees to backend; displays results only.
- [ ] Refunds/voids go through backend; ledger entries verified.
- [ ] Webhooks captured with retry/DLQ; test with CLI/NGROK.
- [ ] Connect onboarding/status surfaced read-only in app Settings.

## 7) Reservations & Tables
- [ ] Overlap warnings & smart suggestions implemented.
- [ ] Statuses: Pending/Confirmed/Seated/Early/Late(+timer)/No-show/Cancelled/Completed.
- [ ] Move/Merge flows preview + irreversible warnings.
- [ ] Reconciliation prompts when conflicts occur after reconnect.

## 8) Delivery & Dispatch
- [ ] Orders panel tabs (Ready/In-Progress/Completed/Problem).
- [ ] Driver panel (status, last seen/live, KPIs).
- [ ] Third-party adapter interface + UberDirect v1 behind feature flag.
- [ ] Geofencing/ETAs verified with mocked positions.

## 9) Menu Editing & Pricing Matrix
- [ ] Reusable add-on sets (required/optional, min/max, included N, per-option price).
- [ ] Per-item/per-size overrides with inheritance precedence documented.
- [ ] Bulk availability & duplicate operations audited.
- [ ] Pos/Online visibility toggles respected across caches.

## 10) Reporting
- [ ] KPI snapshot, trends, funnel & speed gauges render within perf budgets.
- [ ] Export (PDF/XLS) returns correct data + file names with date/vendor.

## 11) Performance Budgets
- [ ] 95th percentile UI action < 250ms local; sync commits < 1s typical.
- [ ] Menu load tested with 2k items, 300 add-ons; Redis caching on server.

## 12) Security Gates
- [ ] Rate limits configured for endpoints touched.
- [ ] No PII in logs/analytics; Sentry PII disabled.
- [ ] CORS rules restricted to approved origins.
- [ ] CSRF (web) and Sanctum token checks confirmed.

## 13) Release Readiness
- [ ] Version bump + changelog.
- [ ] Feature flags staged; migrations applied in staging.
- [ ] Rollback instructions validated.
- [ ] Pilot venue checklist prepared (printers, KDS, delivery).

## 14) Rollback Playbook (per feature)
- [ ] Disable feature flag or route traffic away (server).
- [ ] Revert app feature toggle (remote config where applicable).
- [ ] DB rollback step (if non-additive migration used).
- [ ] Post-mortem issue created with Sentry links and logs.
