# OzPOS Flutter — Project Overview

## High-Level Description

**OzPOS** is a cross-platform Point of Sale (POS) system for restaurants, built as a single Flutter application targeting **Web, iOS, Android, and Windows**. The app aims to unify dine-in (tables + QR), takeaway, delivery/dispatch, kitchen display (KDS/dockets), reservations, loyalty/promotions, and payments—backed by a documented API and security posture.

**Purpose (from PRD):** Deliver a plugin-light, offline-capable, multi-user POS with server-driven payments (Stripe Connect), unified error handling, and Sentry parity.

---

## Target Users

| Role | Usage |
|------|--------|
| **FOH** | Ordering, checkout, split bills, table operations |
| **BOH/KDS** | Ticket lanes, kitchen dockets |
| **Dispatch/Drivers** | Order assignment, status, live/last location |
| **Managers** | Reports, menu editing, settings, Stripe status |

**Environments:** 15.1″ Android terminals, iOS/Android tablets, Windows mini-PCs with USB/LAN printers, modern browsers. Multi-vendor/branch ready per backend.

---

## Core Architecture

The client follows **Clean Architecture** with feature-based modules:

```
lib/
├── core/                    # Shared infrastructure
│   ├── auth/               # AuthCubit, AuthRepository, session timeout
│   ├── config/             # AppConfig, SentryConfig
│   ├── constants/          # AppConstants (API endpoints, timeouts, UI)
│   ├── di/                 # GetIt injection_container + feature modules
│   ├── errors/             # Exceptions, Failures
│   ├── network/            # ApiClient (Dio), retry, certificate pinning
│   ├── navigation/         # AppRouter, NavigationService
│   ├── storage/            # SecureStorageService (tokens)
│   ├── theme/              # AppTheme
│   ├── utils/              # SentryBlocObserver, database_helper, etc.
│   └── validation/         # Input validators, sanitizer
└── features/               # Feature modules
    └── {feature_name}/
        ├── data/           # datasources (remote, mock, [local]), models, repositories
        ├── domain/         # entities, repositories (abstract), usecases, services
        └── presentation/   # bloc, screens, widgets
```

- **State management:** BLoC (flutter_bloc); no Riverpod. Cart and UserManagement are app-wide singletons.
- **Routing:** Custom `AppRouter` with `MaterialPageRoute` and route names; no GoRouter.
- **HTTP:** Dio via `ApiClient` (baseUrl from `AppConfig`), retry interceptor, auth interceptors, optional certificate pinning.
- **Storage:** SQLite (sqflite / sqflite_common_ffi for desktop), SharedPreferences, FlutterSecureStorage for tokens. No Isar/Drift or Hive as in PRD.
- **Backend alignment (PRD):** Laravel 11, Sanctum, MySQL 8, Redis; OpenAPI; Stripe Connect. **No backend code lives in this repo**—Flutter client only.

---

## Modules Explanation

| Module | Responsibility |
|--------|----------------|
| **auth** | Login, logout, token refresh, session timeout; tokens in secure storage. |
| **menu** | Menu grid, categories, modifiers, menu editor, item wizard; GetMenuItems, GetMenuCategories, price/modifier validation. |
| **checkout** | Cart (CartBloc), checkout screen, payment method selection, split payment (tenders), discounts/vouchers, loyalty redemption, ProcessPayment use case. |
| **orders** | Order list (Active/Completed/Cancelled), order cards, payment status; remote + mock + local datasources. |
| **tables** | Table list, move/merge flows, table selection; GetTables, GetAvailableTables. |
| **reservations** | Reservation list, form modal; statuses: pending, confirmed, seated, cancelled (PRD also requires Early, Late, No-show, Completed). |
| **delivery** | Delivery screen, drivers, jobs, KPIs; add driver modal. |
| **reports** | Reports screen, KPI snapshot, payment methods, trends, export hooks. |
| **printing** | Printer list, add/edit printer, test print; ESC/POS + OS print. |
| **customer_display** | Customer-facing display (order, totals, loyalty, payment approved/declined). |
| **combos** | Combo CRUD, slots, pricing, options, limits, availability; combo builder UI. |
| **addons** | Add-on categories management. |
| **settings** | Settings screen, categories, appearance, status overview. |
| **docket** | Docket designer (templates, components: text, variable, logo, table, QR, etc.). |
| **users** | User management (list, add, edit). |
| **dashboard** | Dashboard screen (entry point after login). |

---

## Data Flow

1. **Auth:** User logs in → `AuthRepository` → POST `/auth/login` → tokens stored in `SecureStorageService`; `AuthCubit` holds session state; route guard redirects unauthenticated users to login.
2. **Feature data:** BLoC dispatches events → Use case → Repository → Remote (and optionally Local/Mock) DataSource → API client (Dio) or local DB/cache. Results mapped to entities and returned to BLoC.
3. **Checkout:** Cart (CartBloc) → Checkout screen → Select payment, apply discounts/loyalty → ProcessPayment use case → `PaymentProcessor` (currently **SimulatedPaymentProcessor** only; no Stripe Connect in client).
4. **Offline/Sync:** **Not implemented.** No ETag/read-through cache, no write-behind outbox, no idempotency keys in this codebase. Connectivity is used (e.g. NetworkInfo) but no offline queue or conflict resolution.

---

## Tech Stack Summary

| Layer | Choice in Codebase | PRD / Checklist |
|-------|--------------------|------------------|
| State | BLoC | Riverpod or Bloc ✓ |
| Routing | Custom AppRouter | GoRouter — **not used** |
| HTTP | Dio | Dio ✓ |
| Local DB | SQLite (sqflite) | Isar or Drift — **different** |
| KV cache | SharedPreferences (flags) | Hive — **not used** |
| Tokens | flutter_secure_storage | Secure storage ✓ |
| Printing | esc_pos_* + OS | ESC/POS + OS ✓ |
| Telemetry | sentry_flutter | Sentry ✓ |
| Payments | Simulated only | Stripe Connect server-driven — **not implemented** |

---

## Document References

- **prd.md** — Product scope, NFRs, data model, implementation phases.
- **LIVING_CHECKLIST.md** — Objectives, golden rules, pre-PR, feature DoD, offline, printing, payments, reservations, delivery, menu, reporting, security, release.
- **json_rules.md** — Code generation rules: feature structure, entity/model, datasources (remote/mock/local), repository, use case, BLoC, DI, naming.
