# OZPOS Flutter

OZPOS is a cross-platform restaurant point-of-sale (POS) application targeting web, mobile, and desktop. The project follows Clean Architecture with BLoC state management, GetIt dependency injection, and an offline-first data pipeline so venues keep working even when connectivity drops.

## Highlights
- Single Flutter 3.x codebase for Android, iOS, web, Windows, macOS, and Linux.
- Feature-sliced modules for menu, checkout, combos, tables, orders, delivery, reservations, printing, and settings.
- Mock → local → remote data sources with SQLite caching and sync queue scaffolding.
- Sentry instrumentation for application, bloc, and network errors out of the box.

## Quick Start
1. **Install dependencies**
   ```bash
   flutter pub get
   ```
2. **Run the app (development defaults)**
   ```bash
   flutter run \
     --dart-define=SENTRY_DSN=<your_sentry_dsn> \
     --dart-define=ENVIRONMENT=development \
     --dart-define=API_BASE_URL=http://localhost:8000/api/v1
   ```
3. **Run static analysis and tests**
   ```bash
   flutter analyze
   flutter test
   ```

## Build Targets

| Platform | Command | Notes |
| --- | --- | --- |
| Android | `flutter build apk` | Configure signing in `android/app`. |
| iOS | `flutter build ipa` | Requires Xcode and CocoaPods (`pod install`). |
| Web | `flutter build web` | Outputs static assets to `build/web`. |
| Windows | `flutter build windows` | Needs Visual Studio Build Tools with C++. |
| macOS | `flutter build macos` | Requires Xcode and signing profile. |
| Linux | `flutter build linux` | Needs CMake, Ninja, GTK dev packages. |

## Documentation
- [Full Technical Documentation](OZPOS_FULL_TECHNICAL_DOCUMENTATION.md)
- [Architecture Overview](ARCHITECTURE_OVERVIEW.md)
- Additional historical plans and guides live under `docs/`.

## Troubleshooting
- Menu Item Wizard currently targets an updated entity shape. See `docs/BUILD_ISSUES_AND_FIXES.md` and `docs/STATUS_AND_NEXT_STEPS.md` for alignment steps if the build fails.
- Use mock JSON data in `assets/` while remote endpoints are being finalized.
- Ensure desktop builds call `sqfliteFfiInit()`; this is already handled in `lib/main.dart`.

For deeper background, roadmap, and operational details, start with the full technical documentation linked above.
