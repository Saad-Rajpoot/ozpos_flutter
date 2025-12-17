# OZPOS Flutter – Quick Reference (November 2025)

## 🧱 Architecture at a Glance

- **Pattern**: Clean architecture (BLoC presentation → use cases → repositories → data sources).  
- **Dependency injection**: `GetIt` registrations in `lib/core/di/injection_container.dart`.  
- **Environment toggle**: `AppConfig` selects development (mock JSON assets) or production (REST API).  
- **Navigation**: Centralised in `AppRouter`; `NavigationService` provides global navigation/snackbar helpers.  
- **Storage**: `DatabaseHelper` provisions menu/order/table/reservation/printer/cart/sync tables. Checkout writes to SQLite; caching for other features is next.  
- **Observability**: Sentry integration, connectivity monitoring, retry interceptor in `ApiClient`.

## 📁 Directory Structure

```
lib/
├── core/
│   ├── base/
│   ├── config/
│   ├── constants/
│   ├── di/
│   ├── navigation/
│   ├── network/
│   ├── theme/
│   └── utils/
├── features/
│   ├── menu/
│   ├── checkout/
│   ├── addons/
│   ├── combos/
│   ├── orders/
│   ├── tables/
│   ├── delivery/
│   ├── reservations/
│   ├── reports/
│   ├── settings/
│   ├── printing/
│   └── customer_display/
└── main.dart
```

## 🔧 Key Components

| Area | Files / Notes |
| ---- | ------------- |
| Menu BLoC | `lib/features/menu/presentation/bloc` |
| Menu Wizard | `lib/features/menu/presentation/screens/menu_item_wizard_screen.dart` + widgets |
| Checkout | `lib/features/checkout/presentation/bloc`, `CheckoutBloc`, `CartBloc` |
| Data sources | `lib/features/**/data/datasources` (mock + remote implementations) |
| Repositories | `lib/features/**/data/repositories` |
| Use cases | `lib/features/**/domain/usecases` |
| SQLite helper | `lib/core/utils/database_helper.dart` |
| Navigation | `lib/core/navigation/app_router.dart`, `navigation_service.dart` |
| DI setup | `lib/core/di/injection_container.dart` |

## 🧪 Testing & Tooling

- Lint: `flutter analyze`  
- Tests: `flutter test` (expand coverage with `mocktail`)  
- Logs: Sentry + BLoC observer  
- Mock data: `assets/**` directories per feature

## 🛠 Commands

```bash
flutter pub get
flutter run                          # development (mock data)
flutter run --dart-define=APP_ENV=production
flutter build apk --dart-define=APP_ENV=production
flutter build web  --dart-define=APP_ENV=production
```

## 📚 Reference Docs

- `OFFLINE_FIRST_GUIDE.md` – Data & caching strategy  
- `STATUS.md` / `STATUS_UPDATED.md` – Current status snapshots  
- `FINAL_STATUS.md` – Feature-by-feature summary  
- `FLUTTER_CONVERSION_GUIDE.md` – Architecture breakdown  
- `MENU_EDITOR_WIZARD_IMPLEMENTATION.md` – Wizard details

## 🚀 Next Focus

- Implement caching + sync queue worker.  
- Wire production REST APIs and add DTO contract tests.  
- Expand automated test coverage (repositories, BLoCs, end-to-end flows).  
- Configure Sentry + CI/CD with `--dart-define` secrets.  
- Profile performance once real data is connected.

---

Use this sheet as a quick refresher on where things live and how to run the project across environments. ✅
