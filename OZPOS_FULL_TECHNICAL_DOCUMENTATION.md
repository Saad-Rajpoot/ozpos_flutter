# OZPOS Flutter – Full Technical Documentation

_Last updated: November 10, 2025_

This document provides a consolidated technical reference for the OZPOS Flutter codebase. It expands on existing architecture notes and captures the current system shape, build setup, cross-cutting services, feature coverage, and the strategic roadmap for reaching production readiness.

---

## 1. Project Overview

- **Goal:** Cross-platform restaurant point-of-sale (POS) suite spanning dine-in, takeaway, delivery/dispatch, reservations, loyalty, and back-office management.
- **Tech stack:** Flutter 3.x, Dart 3.x, Clean Architecture, BLoC state management, GetIt DI, Dio networking, SQLite + offline-first sync, Sentry telemetry.
- **Platforms supported:** Android, iOS, Web, Windows, macOS, Linux (`android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/` directories are present and buildable with platform-specific tooling).
- **Code organization:** Feature-sliced structure with reusable primitives in `lib/core` and business capabilities under `lib/features/<domain>`.

### Status Snapshot

| Area | Status | Notes |
| --- | --- | --- |
| **Architecture** | ✅ Stable | Clean three-layer separation with DI and state management conventions already in place (`ARCHITECTURE_OVERVIEW.md`). |
| **Feature coverage** | 🔄 ~75% MVP | Combos, menu management, checkout, and cart flows are functional; tables, reservations, delivery, and printing have UI scaffolding with mock/local data. |
| **Data sources** | 🔄 Mixed | Mock JSON and SQLite-backed flows are complete; remote APIs are stubbed via `AppConstants`. |
| **Testing** | ⚪ Minimal | Only default widget test present; unit/integration suites still required. |

---

## 2. Build & Environment Setup

### 2.1 Prerequisites

- Flutter SDK 3.35+ (`flutter --version`)
- Dart SDK bundled with Flutter
- Platform toolchains:
  - Android Studio or command-line Android SDK/NDK
  - Xcode (for iOS/macOS), CocoaPods
  - Visual Studio Build Tools (Windows)
  - CMake, Ninja (desktop targets)
- Firebase CLI (optional, for sync services)

Run `flutter pub get` after cloning to fetch dependencies.

### 2.2 Environment Configuration

Configuration is centralized through compile-time `--dart-define` values and `AppConfig` (`lib/core/config/app_config.dart`).

| Variable | Purpose | Default |
| --- | --- | --- |
| `SENTRY_DSN` | Error telemetry endpoint (`lib/core/config/sentry_config.dart`) | Non-empty test DSN baked in; override for production. |
| `API_BASE_URL` | Override for API host | Uses `https://api.ozpos.com/v1` (prod) or `http://localhost:8000/api/v1` (dev). |
| `ENVIRONMENT` | `development` or `production` | Defaults to `development`. |

Example development run:

```bash
flutter run \
  --dart-define=SENTRY_DSN=<dsn> \
  --dart-define=ENVIRONMENT=development \
  --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

Production build workflows should source secrets from CI/CD vaults (`docs/ENV_SETUP.md` includes GitHub Actions and GitLab examples).

### 2.3 Platform Targets

| Platform | Command | Notes |
| --- | --- | --- |
| Android | `flutter build apk` | Configure signing in `android/app/build.gradle.kts`. |
| iOS | `flutter build ipa` | Requires `pod install` inside `ios/`. |
| Web | `flutter build web` | Outputs SPA to `build/web`. |
| Windows | `flutter build windows` | Needs Visual Studio with C++ workload. |
| macOS | `flutter build macos` | Requires Xcode and code signing setup. |
| Linux | `flutter build linux` | Requires GTK, CMake, Ninja packages. |

All targets share a single codebase with adaptive UI (`AppTheme` + responsive layout constants).

---

## 3. Application Startup Flow

`lib/main.dart` orchestrates initialization:

1. **Bootstrap:** Ensures Flutter bindings, seeds `SentryBlocObserver`, and configures environment via `AppConfig.instance.initialize`.
2. **Platform services:** Registers `sqflite_common_ffi` for desktop builds and global SQLite factory.
3. **Dependency injection:** Invokes `di.init()` (`lib/core/di/injection_container.dart`) to register core services, data sources, repositories, use cases, and BLoCs.
4. **Error handling:** Wires `_setupErrorHandlers()` to route Flutter and platform errors through Sentry (`SentryConfig`).
5. **Telemetry launch:** Runs `runApp` directly or via `SentryFlutter.init` depending on configuration.
6. **Root widget:** `OzposApp` builds a `MultiBlocProvider` with globally scoped blocs (`CartBloc`) and renders `MaterialApp` configured with:
   - Theming from `AppTheme`
   - `NavigationService.navigatorKey` for context-free navigation
   - `AppRouter.generateRoute` for centralized routing
   - `SentryNavigatorObserver` for navigation traces
   - `AppRouter.dashboard` as the initial route

---

## 4. Architecture Overview

### 4.1 Clean Architecture Layers

```
Presentation (Widgets, Screens, BLoCs)
         ↑ uses
Domain (Entities, Use Cases, Repository Interfaces)
         ↑ implemented by
Data (Repositories, Data Sources, Models)
```

- **Presentation:** Flutter UI widgets and screens under `lib/features/<feature>/presentation`. Blocs extend `BaseBloc` to enforce consistent equality and event/state typing.
- **Domain:** Pure Dart layer containing entities, enums, use cases, and repository abstractions (`lib/features/<feature>/domain`). Use cases return `Either<Failure, T>` with failures defined in `lib/core/errors/failures.dart`.
- **Data:** Concrete repositories and sources translating between transport models and domain entities. Data sources follow a **Mock → Local → Remote** progression driven by environment and availability.

### 4.2 Dependency Injection

- Implemented with GetIt via `lib/core/di/injection_container.dart`.
- Registrations are grouped by feature (`_initMenu`, `_initCheckout`, …) and automatically select mock/local/remote sources:
  - Development defaults to JSON-backed mock sources in `assets/`.
  - Production favors remote sources using `ApiClient`.
  - Some features (checkout, customer display) fall back to mock/local based on SQLite availability.
- Services such as `NetworkInfo`, `ApiClient`, `SharedPreferences`, and `DatabaseHelper` are wired once and shared.

### 4.3 State Management

- **BLoC pattern** standardized via `BaseBloc`, `BaseEvent`, `BaseState`.
- `CartBloc` is registered as a lazy singleton to persist cart state across the entire session.
- Feature-specific blocs are factory-registered to ensure fresh instances per route.
- `SentryBlocObserver` captures lifecycle events and errors for observability.

### 4.4 Navigation

- `NavigationService` offers context-free navigation with a global key.
- `AppRouter` enumerates every route and injects the necessary blocs using GetIt at navigation time. Major screens include:
  - Dashboard, Menu, Checkout, Orders, Tables, Delivery, Reservations, Reports
  - Settings, Menu Editor, Menu Item Wizard, Add-on Management
  - Printing Management, Customer Display, Docket Designer
- Utility helpers provide snackbars, dialogs, and route introspection.

### 4.5 Theming & UI Foundation

- `AppTheme` exposes Material 3 light/dark themes with shared typography (`lib/core/constants/app_typography.dart`), spacing (`app_spacing.dart`), and color palette (`app_colors.dart`).
- Layout breakpoints (`app_responsive.dart`, `grid_columns.dart`) drive adaptive grid and sidebar experiences across desktop/tablet/mobile.

---

## 5. Data Access & Offline Strategy

### 5.1 Data Source Tiers

| Tier | Implementation | Usage |
| --- | --- | --- |
| **Mock** | `*_mock_datasource.dart` reading seeded JSON from `assets/**` | Default during development and test drives. |
| **Local** | `*_local_datasource.dart` backed by SQLite via `DatabaseHelper` | Offline-first support, caching, sync queue management. |
| **Remote** | `*_remote_datasource.dart` issuing HTTP requests via `ApiClient` (Dio) | Production-grade API integration; currently stubbed with endpoint constants. |

`AppConfig.instance.environment` determines the tier; additional logic checks for SQLite availability when deciding between local or mock flows (e.g., checkout).

### 5.2 Offline-First Mechanics

Documented in `docs/OFFLINE_FIRST_GUIDE.md` and implemented via `DatabaseHelper`:

- Comprehensive schema covering menu, orders, modifiers, tables, reservations, printers, cart items, and a `sync_queue`.
- Write operations:
  1. Persist to SQLite.
  2. Append to `sync_queue` for batched uploads when network connectivity returns.
- Read operations always hit local storage for low latency.
- Sync strategy uses periodic jobs (planned in `SyncService`, WIP) and conflict resolution via timestamp-based last-write-wins.

### 5.3 Networking Stack

- `ApiClient` wraps Dio with:
  - Configurable base URL (`AppConstants.baseUrl` or runtime override).
  - Retry policy (`RetryInterceptor`) with retry counters stored in request metadata.
  - Auth interceptor pulling bearer tokens from `SharedPreferences`.
  - Automatic handling of `401` responses (clears credentials, redirects using `NavigationService`).
  - Optional verbose logging in debug builds.
- Future enhancements include request cancellation tracking and centralized error envelopes.

---

## 6. Feature Modules

Each feature follows the convention: `data/`, `domain/`, `presentation/` with dedicated blocs, use cases, entities, and UI. Highlights:

| Feature | Key Components | Current State |
| --- | --- | --- |
| **Dashboard** | Aggregated metrics, quick navigation cards | UI scaffolding with mock data. |
| **Menu** | `MenuBloc`, menu grid, editor screens, wizard | Core browsing works; new item wizard requires entity alignment (`docs/BUILD_ISSUES_AND_FIXES.md`). |
| **Checkout & Cart** | `CartBloc`, `CheckoutBloc`, order summary widgets | Functional with mock/local data; payments simulated via `SimulatedPaymentProcessor`. |
| **Combos** | CRUD/edit/filter blocs, availability/pricing logic | End-to-end implemented with validation and pricing calculators. |
| **Add-ons** | Category fetch and management screens | Mock data support, navigation integrated. |
| **Tables & Reservations** | Table management bloc, move table dialog, reservations CRUD | Mock implementations ready; real-time updates pending. |
| **Orders** | Order history list, status indicators | Mock/local data; remote integration TBD. |
| **Delivery** | Driver and delivery boards | Uses mock JSON, remote service layer scaffolding prepared. |
| **Customer Display** | Secondary screen view with order summary | Supports mock/local data sources. |
| **Printing** | Printer management, ESC/POS integration stubs | Mock data with remote endpoints defined for future hardware integration. |
| **Reports** | KPI cards, charts via `fl_chart` | Mock data, awaiting backend endpoints. |
| **Settings** | Config categories, toggles | Mock data and DI ready. |
| **Docket Designer** | Placeholder screen for print layout designer | UI stub only. |

Feature modules share helper widgets, constants, and domain definitions to encourage reuse and consistent behavior.

---

## 7. Cross-Cutting Services

- **Sentry (`lib/core/services/sentry_service.dart`):** Unified error and performance tracking with convenience helpers for POS scenarios, payments, database operations, and BLoC errors.
- **NetworkInfo (`lib/core/network/network_info.dart`):** Connectivity checks via `connectivity_plus` to inform offline/online flows.
- **NavigationService:** Global navigation, snackbars, and dialogs.
- **Theme & Design Tokens:** Colors, typography, spacing, grid sizes to maintain a consistent brand experience.
- **Utilities:** Exception helpers, UUID generation, shared preferences accessors, and device-aware toggles.

---

## 8. Dependency Inventory

Key packages from `pubspec.yaml`:

- **State & DI:** `flutter_bloc`, `bloc`, `get_it`, `equatable`, `dartz`
- **Data & Storage:** `sqflite`, `sqflite_common_ffi`, `shared_preferences`, `path`, `path_provider`
- **Networking:** `dio`, `connectivity_plus`
- **UI Enhancements:** `cached_network_image`, `shimmer`, `fl_chart`, `intl`, `fluttertoast`
- **Hardware & Printing:** `esc_pos_printer`, `esc_pos_utils`
- **Telemetry:** `sentry_flutter`, `package_info_plus`
- **Dev/Test:** `flutter_test`, `flutter_lints`, `mocktail`

All chosen packages are cross-platform compatible and aligned with the offline-first, POS-heavy requirements.

---

## 9. Testing & Quality

### Current Coverage

- Only the default `test/widget_test.dart` exists. No bespoke unit, bloc, or integration tests are committed yet.

### Recommended Strategy

1. **Unit tests** for use cases and repositories, leveraging mocks (`mocktail`).
2. **Bloc tests** validating event-to-state transitions (use `bloc_test` package).
3. **Widget tests** for critical screens (menu grid, checkout flow).
4. **Integration tests** simulating end-to-end checkout, including offline sync scenarios.
5. **Golden tests** for stable UI components (menu cards, order tiles).
6. **Continuous integration** pipeline running `flutter analyze`, `flutter test`, and platform smoke builds.

---

## 10. Known Gaps & Risks

- **Menu Item Wizard alignment:** Wizard assumes entity fields (`imageUrl`, `categoryId`, `badges`) that differ from current `MenuItemEditEntity`. Build breaks until adapters or refactors are applied (`docs/BUILD_ISSUES_AND_FIXES.md`, `docs/STATUS_AND_NEXT_STEPS.md`).
- **Remote API integration:** No live backend wiring yet; all remote data sources rely on endpoint constants but lack implementations.
- **Offline sync scheduling:** Sync orchestration is partially drafted; step-by-step scheduler and conflict handling require completion.
- **Testing debt:** Lack of automated tests increases regression risk.
- **Security hardening:** Token refresh, secure storage, OAuth/device login, and audit logs are TODOs.
- **Hardware integration:** ESC/POS printing, scanners, and payment terminals are stubbed.

---

## 11. Roadmap

### 11.1 Immediate (Week 0–1)

- Align menu wizard entities or temporarily disable wizard to restore clean build.
- Introduce adapter layer or reconcile domain models (`menu_item_edit_entity.dart`, wizard bloc files).
- Stand up basic CI pipeline (analyze, test, build) to prevent future regressions.
- Document quick-start commands in README (see Section 12).

### 11.2 Near-Term (Month 1)

- Implement backend integration for menu, checkout, orders, tables using `ApiClient`.
- Flesh out offline sync service (scheduled batch uploads, retry policy).
- Add bloc/unit tests for high-traffic features (menu, cart, checkout, combos).
- Finish table management flows (move/merge, QR linkage) and reservations CRUD.
- Enhance reporting dashboards with real metrics.

### 11.3 Mid-Term (Quarter 1)

- Integrate Stripe Connect for payments and payouts.
- Build loyalty, promotions, and voucher subsystems end-to-end.
- Complete driver and dispatch module with real-time updates.
- Add printer discovery, routing, and ESC/POS command customization.
- Harden security (secure storage, multi-user auth, audit trails).

### 11.4 Long-Term (Quarter 2+)

- Multi-tenant support, advanced analytics/BI integrations.
- Hardware peripherals (barcode scanners, customer-facing displays) with platform channels.
- Performance profiling and optimization across large restaurant datasets.
- Robust monitoring playbook (Sentry, metrics dashboards, alerting).

---

## 12. README Quick Reference

For convenience, the README should direct developers to:

1. Project synopsis and screenshots (if available).
2. Core commands:
   - `flutter pub get`
   - `flutter run --dart-define=...`
   - `flutter test`
3. Link to this document for in-depth details.
4. Troubleshooting guidance (wizard build issues, sync errors).

---

## 13. Additional Resources

- `ARCHITECTURE_OVERVIEW.md` – Clean Architecture primer for this project.
- `OFFLINE_FIRST_GUIDE.md` – Detailed offline/sync design.
- `PROJECT_ANALYSIS_REPORT.md` – High-level status report and PRD alignment.
- `docs/` directory – Contains historical plans, PRDs, and feature-specific walkthroughs (addons, checkout, combos, wizard, navigation).

---

### Summary

The OZPOS Flutter project already exhibits strong architectural foundations and cross-platform readiness. The remaining work primarily centers on reconciling new feature work (menu wizard), fleshing out remote integrations, and establishing the automated quality gates necessary for production deployments. This document should serve as the authoritative starting point for onboarding contributors, planning upcoming sprints, and keeping technical debt in check.

