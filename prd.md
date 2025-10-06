PRD — OzPOS Cross-Platform Flutter POS (Web • iOS • Android • Windows)
1) Purpose & Goals
Deliver a plugin-light, offline-capable, multi-user POS that unifies dine-in (tables + QR), takeaway, delivery/dispatch, KDS, reservations, loyalty/promotions, payments (Stripe Connect), and a light in-app menu editor—backed 1:1 by our documented API/validation/security posture and release workflows.
Success criteria
Single Flutter codebase builds to Web/iOS/Android/Windows with >90% shared code.
Robust offline (read-through cache + write-behind outbox) for orders, tables, reservations, drivers, and menu deltas.
Payments & vendor payouts are server-driven via Stripe Connect (client shows status only).
Unified error envelope + Sentry parity with backend (vendor/order context).
2) Users & Environments
FOH (ordering, checkout, split bills, table ops), BOH/KDS (ticket lanes), Dispatch/Drivers, Managers.
Devices: 15.1″ Android terminals, iOS/Android tablets, Windows mini-PCs with USB/LAN printers, modern browsers. (Multi-vendor/branch ready per backend.)
3) Product Scope (v1)
A. POS & Ordering
Menu grid (categories/search/quick filters), modifier/add-on modal with rules (min/max, required, included N), per-size add-on pricing with live totals.
Cart pane: notes, upsells, discounts/vouchers, tips.
Checkout: cash, card, split payment, pay later, voucher, loyalty earn/redeem, keypad, remaining-due banner.
Split Bill: by person/item/equal/custom; drag-assign; per-split payment; reconcile remaining due.
B. Loyalty & Promotions
Customer link/lookup, points balance, earn preview, thresholds, max redeem %, partial redemption.
Auto-nudges when points available; voucher/QR promos; “best value” conflict resolution.
C. Table Management
Move/Merge tables with preview and irreversible-action warnings; zone/level filters; optional heatmap/occupancy later.
Table sessions with timers; QR table linkage and handoff to KDS.
D. Multi-Source Order History
Unified order cards with source badges (UberEats, DoorDash, Menulog, Website, App, QR), timestamps, payment status, and actions (KOT, pay, dispatch/complete).
Tabs: Active/Completed/Cancelled; compact vs expanded. (Third-party orders are read-only where applicable; status sync via adapters.)
E. Printer Management
Printer dashboard (role: Receipt/Kitchen/Backup; connection: LAN/BLE/USB), online/offline state, category routing, “Test Print.”
Add/Configure wizard with auto-detect, troubleshooting hints.
F. Menu Editing (Ops-safe)
Menu dashboard: category rail; inline price edits & POS/Online toggles; “Save All.”
Add/Edit Item Wizard: Item → Sizes → Add-ons → Pricing & Availability → Review.
Pricing Matrix: per-item/per-size override with inheritance from add-on set base price.
Reusable add-on sets (required/optional, min/max, included N, per-option price); duplicate/reorder/bulk availability.
G. Delivery Driver Manager
Orders panel: Ready to Dispatch / In Progress / Completed / Problem.
Driver panel: status, assigned orders, live/last location, KPIs; Live Map with pins/filters/ETAs.
Third-party dispatch hooks (UberDirect/Drive) via adapter + webhook/state sync.
H. Reservations
Lists (Upcoming/Ongoing/Past), search/filters.
New Reservation: smart table suggestions, overlap warnings, fixed-menu attachment, notes.
Statuses: Confirmed, Pending, Seated, Early, Late (+timer), No-show, Cancelled, Completed.
Tight table integration (assign/reassign with conflict prompts).
I. Reporting & Ops
KPIs: Sales, AOV, Orders, Turnover time, Gross Margin %, Loyalty activity.
Ops health funnel (Placed→Kitchen→Served→Paid), speed gauge, discounts effect, payments mix.
Trends: hourly sales, category mix, top/under-performers, staff, table utilization.
Export (PDF/XLS) + links into advanced web BI dashboards.
J. Settings
System / User & Access / Operations / Customization; status cards (online/offline, versions, device).
Key toggles: dual screen, printer setup, hot reload (dev), reports, expenses (hook).
Read-only Stripe Connect onboarding/status surface in Settings.
4) Non-Functional Requirements
Performance: >60 FPS UI; 95th percentile local actions <250 ms; normal sync commits <1 s.
Resilience: graceful degradation + circuit-breakers; idempotent mutations.
Security: TLS, secure token storage, no secrets in app, strict logging/PII minimization.
Documentation parity: endpoints fully annotated in OpenAPI; CI validation.
5) System Architecture
Client (Flutter) — Clean architecture
Presentation: BLoC Pattern (flutter_bloc) + Navigator 2.0 with AppRouter; module UIs (POS, KDS, Dispatch, Reservations, Printers, Settings).
Domain: Entities (Menu/Item/Modifier/Groups, Order, Table, Reservation, Driver, Loyalty, Printer), Use-cases (PlaceOrder, UpdateStatus, SplitPay, AssignDriver, RedeemLoyalty, MoveTable…), Policies (SyncConflict, Pricing, Access).
Data: Repositories (abstract), Local DB (SQLite), KV cache (Hive), Remote (Dio + interceptors: auth, retry, ETag).
Platform: printing (ESC/POS + OS print), camera/QR, secure storage, notifications, Sentry telemetry.
Offline & Sync
Read-through cache for menus/reservations (ETags/updated_at watermarks).
Write-behind outbox for mutations (orders, table ops, reservations, driver status) with idempotency keys + exponential backoff.
Conflict policy:
Orders: server-enforced state machine; client reconciles invalid transitions.
Tables/Reservations: server timestamp precedence; client prompts reconciliation.
Menu edits: last-writer-wins with audit surfaces.
Realtime
Laravel Echo/SSE (or Pusher/Redis) channels for order status, KDS lanes, dispatch/driver ticks, and printer webhooks → UI streams.
Backend Alignment
Laravel 11, Sanctum, MySQL 8, Redis queues/caching; OpenAPI docs/CI; Sentry; Security headers middleware; Form Requests.
Stripe Connect: onboarding & status via server; payment intents + fees computed server-side; client displays results. Webhooks: /api/webhook/stripe and /api/webhook/stripe/connect.
6) Tech Choices (plugin-light)
State: BLoC Pattern (flutter_bloc) - deterministic, testable, follows Clean Architecture.
HTTP: Dio (+ retry/backoff, auth, logging in dev).
Models: Freezed + JsonSerializable.
Storage: SQLite + Hive (KV); SharedPreferences for tokens (key name: 'token').
Routing: Navigator 2.0 with custom AppRouter (centralized route management).
QR/Camera: camera + barcode_scan2 (or MLKit on web via JS interop if needed).
Printing: printing (OS print/AirPrint) + lightweight ESC/POS (LAN socket first; BLE/USB behind platform channel abstraction).
Telemetry: sentry_flutter (PII off; vendor/order tags).
Dependency Injection: GetIt (service locator pattern).
7) API Contracts (selected)
/auth/* (login/logout/refresh); /orders CRUD + /orders/{id}/pay, /split/*; /tables/move|merge; /menu/* (items/sizes/add-on sets/matrix overrides); /printers/* + /printers/{id}/test; /loyalty/*; /dispatch/jobs, /drivers/*; /reservations/*; /reports/*. All FormRequest-validated + rate-limited + documented via annotations and CI linting.
8) Security & Compliance
Sanctum tokens (device-scoped) stored with key name 'token'; CSRF for Web; strict CORS; Security Headers middleware (HSTS, CSP, X-Frame-Options, X-Content-Type-Options).
Secrets via .env; no hardcoded keys; audit trails (payments, dispatch, menu edits, reservations).
PII minimization in logs; Sentry PII disabled; vendor scoping in events.
9) Observability & Error Handling
Standardized error envelope with user-safe messages, retry affordances, and actionable codes (422/400/402/502/500).
Sentry: screen + network breadcrumbs; tags: vendor_id, user_role, order_id, integration_service. Backend parity.
10) Data Model (essentials)
Items/Categories/Sizes/Addons/AddOnSets/AddOnOptions/ItemAddOnSets/ItemAddOnPriceOverrides(size_id?).
Orders/OrderItems/OrderItemAddons/Payments/Splits.
Tables/TableAreas/TableSessions.
Printers/PrinterRoles/PrinterRoutes(category_id→printer_id).
Customers/LoyaltyAccounts/Ledger.
Drivers/DispatchJobs/DriverLocations.
Reservations/ReservationTables/ReservationMenus.
11) Implementation Plan (12 weeks)
Phase 0 — Foundations (W1)
Repo bootstrap; CI/CD; OpenAPI skeleton (auth + GET items); theming tokens; mock server & Postman sync.
Phase 1 — Menu & Checkout Core (W2-3)
Menu grid + modifiers; Cart + unified checkout (cash/card/split/voucher/tips); loyalty surface; KOT/receipt printing (LAN first). ✅ Acceptance: place & pay order → KOT prints → loyalty updated.
Phase 2 — Tables & Split (W4-5)
Table sessions; Move/Merge; Split Bill flows (item/person/equal/custom). ✅ Acceptance: turnover + reconciled splits.
Phase 3 — Menu Editor Pro (W6-7)
Item wizard; Pricing Matrix; reusable add-on sets; bulk toggles; duplicate. ✅ Acceptance: create complex item (sizes + sets + overrides) and sell it.
Phase 4 — Orders/Drivers/Dispatch (W8-9)
Unified history/sources; Driver Manager; third-party adapter (UberDirect v1). ✅ Acceptance: dispatch to self-driver & partner, track to completion.
Phase 5 — Reservations & Reporting (W10)
Reservation lifecycle + table integration; KPI/Trends + export. ✅ Acceptance: late seating with reassignment; daily PDF/XLS export.
Phase 6 — Settings, Hardening, Release (W11-12)
Settings hub; advanced printer detect; expenses hook (basic); full test pass; security headers; perf tuning; pilot rollout.
12) Testing & Release
Backend: Feature + integration tests; OpenAPI CI; security headers middleware; FormRequests.
Client: Unit (view-models, repos, sync); Widget/Golden (modifiers, split, KDS lanes); Integration (login→order→pay→print→loyalty); offline/print scenarios.
Perf/Load: menu 2k items + 300 add-ons; Redis caches; concurrent KOT prints.
Rollbacks: server-side feature flags; additive DB migrations; versioned local DB schema; Sentry release pin.
13) Risks & Mitigations
Printer heterogeneity → dual pipeline (OS print + ESC/POS LAN), diagnostics, test print.
Partner API variance → adapter pattern + webhooks + DLQ + feature flags.
Offline conflicts → strict state machines, reconciliation UI, idempotent writes.
Security regressions → CI lint + headers middleware + rate limits + Sentry alerts.