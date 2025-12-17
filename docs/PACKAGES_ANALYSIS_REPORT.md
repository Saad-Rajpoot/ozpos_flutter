# OZPOS Flutter – Package Analysis (November 2025)

*Flutter SDK 3.27.x | Dart SDK 3.5.x*

## 📌 Executive Summary

- **Runtime packages**: 24 (excluding the core `flutter` SDK entry)  
- **Dev packages**: 3 (`flutter_test`, `flutter_lints`, `mocktail`)  
- **Cross-platform coverage**: 100% of packages support iOS, Android, Web, Windows, macOS, and Linux.  
- **Security**: All packages are maintained by trusted publishers (Flutter Team, Dart Team, Felix Angelov, Sentry, etc.).  
- **Firebase footprint**: None – the app currently targets REST APIs and local storage only.

```31:106:pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_bloc: ^8.1.6
  bloc: ^8.1.4
  get_it: ^7.7.0
  dartz: ^0.10.1
  equatable: ^2.0.5
  sqflite: ^2.3.2
  sqflite_common_ffi: ^2.3.2+1
  path: ^1.9.0
  path_provider: ^2.1.2
  connectivity_plus: ^5.0.2
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  image_picker: ^1.0.7
  fl_chart: ^0.66.0
  fluttertoast: ^8.2.4
  intl: ^0.19.0
  uuid: ^4.3.3
  shared_preferences: ^2.2.2
  esc_pos_printer: ^4.1.0
  esc_pos_utils: ^1.1.0
  dio: ^5.7.0
  sentry_flutter: ^7.10.0
  package_info_plus: ^8.2.0
```

## 🧱 Dependency Categories

### 1. Architecture & State

| Package | Role |
| ------- | ---- |
| `flutter_bloc`, `bloc` | BLoC state management for every feature module |
| `get_it` | Service-locator DI container |
| `dartz`, `equatable` | Functional primitives (`Either`, `Option`) and value equality |

### 2. Data & Persistence

| Package | Role |
| ------- | ---- |
| `sqflite`, `sqflite_common_ffi` | SQLite across mobile + desktop |
| `path`, `path_provider` | File system paths and helpers |
| `shared_preferences` | Key-value storage for lightweight settings |
| `uuid` | Primary key generation |

### 3. Networking & Observability

| Package | Role |
| ------- | ---- |
| `dio` | HTTP client with interceptors (retry, auth, logging) |
| `connectivity_plus` | Online/offline detection |
| `sentry_flutter`, `package_info_plus` | Crash reporting, release metadata |

### 4. UI & Media

| Package | Role |
| ------- | ---- |
| `cupertino_icons` | iOS-styled icons |
| `cached_network_image`, `shimmer` | Image caching + skeleton loading |
| `image_picker` | Media capture/upload |
| `fl_chart` | Analytics charts |
| `fluttertoast` | Toast notifications |

### 5. Printing & POS

| Package | Role |
| ------- | ---- |
| `esc_pos_printer`, `esc_pos_utils` | ESC/POS printing integration for receipts |

## 🔍 Observations

- **Lean footprint** – The dependency list focuses on core frameworks. There are no heavy UI kits, no Firebase SDKs, and no codegen packages beyond DI/BLoC needs.  
- **Offline-ready stack** – SQLite packages cover all platforms through FFI; only final caching logic needs implementation.  
- **POS-specific tooling** – ESC/POS libraries add ~200KB but are required for receipt printing; evaluate feature flags if shipping a build without printers.  
- **Network resilience** – `dio` + retry interceptor + `connectivity_plus` provide a solid foundation for resilient API calls once the backend is connected.  
- **Observability** – Sentry is already wired; ensure DSN and environment values are supplied through `--dart-define` in CI/CD.

## 📊 Cross-Platform Matrix

| Category | iOS | Android | Web | Windows | macOS | Linux |
| -------- | --- | ------- | --- | ------- | ----- | ----- |
| Architecture & state | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Data & persistence | ✅ | ✅ | ✅* | ✅ | ✅ | ✅ |
| Networking & observability | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| UI & media | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Printing | ✅† | ✅† | ✳️‡ | ✅ | ✅ | ✅ |

- *`sqflite` uses `sqflite_common_ffi_web` internally for web builds.*  
- † Printer support depends on platform-specific device drivers.  
- ‡ ESC/POS printing is not supported in browsers; filter the feature behind platform checks.

## 🛠 Dev & Build Tooling

| Dev Package | Purpose |
| ----------- | ------- |
| `flutter_test` | Widget/unit testing |
| `flutter_lints` | Static analysis baseline |
| `mocktail` | Mocking for unit tests |

No code generation tools are currently in use; if future features add DTO/model codegen, reintroduce `build_runner` + `json_serializable` as needed.

## 🚧 Next Steps & Recommendations

1. **Cache layer** – Implement repository caching to capitalise on SQLite support; consider introducing Hive/ObjectBox only if domain requirements change.  
2. **Printer abstraction** – Wrap ESC/POS usage behind a repository/service so non-printer builds can exclude it easily (tree-shaking friendly).  
3. **API integration** – As REST endpoints go live, ensure certificates, interceptors, and timeouts are tuned in `ApiClient`.  
4. **Monitoring** – Configure Sentry environment, release, and sample rates via `SentryConfig` before shipping QA builds.  
5. **Security audit** – Add Dependabot or `flutter pub outdated --mode=null-safety` to CI to keep dependencies current.

---

The dependency stack is intentionally minimal and production-ready. Focus upcoming work on wiring real data flows, implementing offline caching, and keeping packages updated as Flutter releases new stable versions. 🧩