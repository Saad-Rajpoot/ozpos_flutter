# OZPOS Flutter – Quick Start

## ✅ What’s Ready Out of the Box

- **Clean architecture foundation** – BLoC-based presentation (`flutter_bloc`) with use cases, repositories, and dependency injection via `lib/core/di/injection_container.dart`.  
- **Environment aware data layer** – `AppConfig` selects mock JSON data in development or REST APIs in production; mock assets cover menu, addons, combos, delivery, reservations, tables, reports, printing, and more.  
- **UI & navigation** – Responsive dashboard, menu, checkout, orders, tables, delivery, reservations, reports, settings, printing, addon management, combo editor, and customer display screens are all wired through `AppRouter`. Each route spins up the feature BLoC automatically.  
- **Design system** – Light/dark themes, typography, color tokens, gradients, spacing, and responsive breakpoints live under `lib/core/theme` and `lib/core/constants`.  
- **Observability** – Sentry, retry-aware `Dio` client, connectivity checks, and structured error handling are enabled from `main.dart`.

## 🚀 Run It

```bash
cd ozpos_flutter
flutter pub get

# default (development) environment uses mock JSON data
flutter run

# specify a device
flutter run -d chrome      # web
flutter run -d windows     # desktop
flutter run -d ios         # simulator

# switch to production wiring
flutter run --dart-define=APP_ENV=production
```

### Environment tips
`AppConfig.instance.initialize(...)` in `lib/main.dart` sets the baseline environment. Supply `--dart-define=API_BASE_URL=https://api.example.com` when pointing to a real backend. No file renames or manual entry-point swaps are required—the canonical entry point is `lib/main.dart`.

## 📁 Project Layout Cheat Sheet

```
lib/
├── core/
│   ├── base/                  # BaseBloc, BaseUseCase abstractions
│   ├── config/                # AppConfig, SentryConfig
│   ├── constants/             # Colors, spacing, endpoints, etc.
│   ├── di/                    # Dependency injection setup
│   ├── navigation/            # Navigation service + AppRouter
│   ├── network/               # ApiClient, interceptors, NetworkInfo
│   ├── theme/                 # Light/Dark themes and tokens
│   └── utils/                 # DatabaseHelper, helpers
├── features/
│   ├── menu/                  # Data, domain, presentation (Bloc + screens)
│   ├── checkout/              # CartBloc, CheckoutBloc, data layer
│   ├── addons/, combos/, ...  # Same pattern repeated per feature
│   └── customer_display/, ... #
└── main.dart                  # App bootstrap (config, DI, Sentry)
assets/
├── menu_data/, checkout_data/ # Mock payloads consumed in dev mode
└── ...                        # (addons, orders, tables, etc.)
```

## 🛠 First Customisations

### Add a new screen + route
1. Create the screen inside the relevant feature (e.g. `lib/features/reports/presentation/screens/my_report_screen.dart`).  
2. Register a route in `AppRouter` and decide which BLoC(s) to provide.  
3. Wire dependencies in `injection_container.dart` if a new use case or repository is required.

```dart
// lib/core/navigation/app_router.dart
case myReports:
  return MaterialPageRoute(
    builder: (_) => BlocProvider<MyReportsBloc>(
      create: (_) => di.sl<MyReportsBloc>()..add(const LoadReports()),
      child: const MyReportsScreen(),
    ),
  );
```

### Access shared dependencies
```dart
final cartBloc = context.read<CartBloc>();      // Global singleton
final apiClient = di.sl<ApiClient>();           // From GetIt
final database = di.sl<Database>();             // When available
```

### Working with mock assets
Mock data lives in `assets/**`. Update JSON payloads to reflect new fields or create failure scenarios by editing the matching `*_error.json` files.

## 🔜 Suggested Next Steps

1. **Offline read caching** – hydrate SQLite tables from assets or REST responses so menu/addon data is available offline.  
2. **Sync queue worker** – turn the existing `sync_queue` table into a background service to replay pending writes.  
3. **API wiring** – swap mock data sources for remote ones in production mode and add DTO → entity tests.  
4. **Testing** – introduce unit tests for repositories/use cases and widget tests for dashboard → checkout.  
5. **Checkout metadata** – add the missing table/seeding required by `CheckoutLocalDataSource`.

## 💡 Tips & Patterns

- Use `flutter pub run build_runner watch` only when code generation is added (not required today).  
- Reuse existing theme helpers (`AppTheme`, `AppColors`, `AppSpacing`) to keep styling consistent.  
- For feature isolation, each `features/<feature>` folder follows the same structure: `data` (datasources + models) → `domain` (entities + repos + use cases) → `presentation` (bloc + screens + widgets).

## 📚 Helpful References

- `README.md` – high-level overview.  
- `OFFLINE_FIRST_GUIDE.md` – detailed data/storage notes.  
- `STATUS.md` – current progress and roadmap.  
- Flutter docs: <https://docs.flutter.dev>  
- flutter_bloc docs: <https://bloclibrary.dev>

## 🐛 Troubleshooting

| Symptom | Fix |
| ------- | --- |
| Missing package / analyzer errors | `flutter clean && flutter pub get` |
| Simulator build issues (iOS) | `cd ios && pod install && cd ..` |
| Android Gradle errors | `cd android && ./gradlew clean && cd ..` |
| Hot reload stale state | Press `R` (hot restart) or restart the app |

## 🔄 React vs Flutter Quick Mapping

| React / TypeScript | Flutter / Dart |
| ------------------ | -------------- |
| `useState`, `useReducer` | `Cubit/BLoC`, `StatefulWidget` |
| Context providers | `BlocProvider`, `InheritedWidget`, `GetIt` |
| React Router | `Navigator`, `AppRouter` |
| CSS / Tailwind | Widget composition + `ThemeData` |
| Fetch + Axios | `Dio` client with interceptors |
| LocalStorage | `SharedPreferences`, SQLite |

---

You’re ready to extend OZPOS in Flutter. Start by enabling caching or wiring real APIs, then iterate feature by feature. 👩‍🍳⚡
