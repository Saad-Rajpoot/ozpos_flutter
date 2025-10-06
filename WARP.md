# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## 🚀 Common Development Commands

### Project Setup
```bash
# Install dependencies (run after git clone or pubspec.yaml changes)
flutter pub get

# Clean build cache (when having build issues)
flutter clean && flutter pub get

# Code generation (when modifying .freezed or .g.dart files)
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Development & Testing
```bash
# Run analysis (should show 0 issues)
flutter analyze

# Run tests
flutter test

# Run a specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Platform-Specific Runs
```bash
# Web (primary development target - tested and working)
flutter run -d web-server --web-port=5001

# Mobile platforms
flutter run -d ios          # iOS Simulator
flutter run -d android      # Android Emulator

# Desktop platforms  
flutter run -d macos        # macOS
flutter run -d windows      # Windows
flutter run -d linux        # Linux

# Debug specific platform
flutter run -d chrome --debug
```

### Build Commands
```bash
# Web build (production)
flutter build web --release

# Mobile builds
flutter build ios --release
flutter build android --release --split-per-abi

# Desktop builds
flutter build macos --release
flutter build windows --release  
flutter build linux --release
```

### Database & Code Generation
```bash
# Generate models (when adding new .freezed.dart files)
flutter packages pub run build_runner build

# Watch mode for continuous generation during development
flutter packages pub run build_runner watch

# Clean generated files and rebuild
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 🏗️ Architecture Overview

### Clean Architecture Pattern
This codebase follows **Clean Architecture** with **offline-first design**:

```
lib/
├── core/                          # Shared infrastructure
│   ├── di/                        # Dependency Injection (GetIt)
│   ├── navigation/                # App routing
│   ├── network/                   # API client & connectivity
│   ├── utils/                     # Database helper
│   └── errors/                    # Error handling
├── features/                      # Business features
│   ├── pos/                       # POS core functionality
│   │   ├── data/                  # Data layer
│   │   │   ├── datasources/       # Local & Remote data sources
│   │   │   ├── repositories/      # Repository implementations
│   │   │   └── models/            # Data models (.freezed)
│   │   ├── domain/                # Business logic layer
│   │   │   ├── entities/          # Domain entities
│   │   │   ├── repositories/      # Repository contracts
│   │   │   └── usecases/          # Business use cases
│   │   └── presentation/          # UI layer
│   │       ├── screens/           # 11 complete screens
│   │       └── bloc/              # BLoC state management
│   └── cart/                      # Shopping cart feature
│       ├── data/                  # Cart data layer
│       ├── domain/                # Cart business logic
│       └── presentation/          # Cart UI components
├── theme/                         # Material 3 theming
├── utils/                         # Shared utilities
└── widgets/                       # Reusable UI components
```

### Key Architectural Decisions

**State Management**: BLoC pattern with flutter_bloc
- Separation of business logic from UI
- Predictable state changes  
- Easy testing and debugging
- Event-driven architecture

**Dependency Injection**: GetIt
- Singleton and factory registrations
- Clean separation of concerns
- Easy mocking for tests
- Configured in `core/di/injection_container.dart`

**Database Strategy**: Offline-First with SQLite
- Primary storage: SQLite (sqflite + sqflite_common_ffi for desktop)
- Cloud sync: Firebase Firestore (ready for integration)
- Cross-platform compatibility
- Instant response times

**Navigation**: Custom AppRouter
- Centralized route management
- Type-safe navigation with arguments
- Consistent routing across platforms
- All routes defined in `core/navigation/app_router.dart`

## 📱 Application Features

### Complete Screens (11 total)
1. **Dashboard** - Main navigation hub with gradient tiles
2. **Menu** - Product catalog with categories and cart management
3. **Checkout** - Payment processing with multiple methods
4. **Tables** - Table management with status tracking
5. **Orders** - Order workflow management
6. **Delivery** - Kanban board for delivery tracking
7. **Reservations** - Calendar-based booking system
8. **Reports** - Analytics and reporting dashboard
9. **Settings** - App configuration
10. **Menu Editor** - Product management interface  
11. **Docket Designer** - Receipt template designer

### Data Models
Key entities with Freezed code generation:
- `MenuItem` - Menu products with categories, pricing, availability
- `CartItem` - Shopping cart line items  
- `Order` - Order headers with customer details
- `Table` - Restaurant table management
- `Reservation` - Booking information

### Database Schema (8 Tables)
- `menu_items` - Product catalog
- `modifier_groups` & `modifiers` - Product customization options
- `orders` & `order_items` - Order management
- `tables` - Table status tracking
- `reservations` - Booking data
- `sync_queue` - Offline change tracking for cloud sync

## 🎨 UI/UX Guidelines

### Theme System
- **Material 3** design system with custom tokens
- **Gradient-based** color schemes matching business needs:
  - Takeaway: Orange (#F97316 → #F59E0B)
  - Dine In: Green (#10B981 → #059669) 
  - Tables: Blue (#3B82F6 → #2563EB)
  - Delivery: Purple (#A855F7 → #C026D3)
  - Dashboard: Red (#EF4444 → #DC2626)

### Responsive Design
- **Mobile** (<768px): Bottom navigation, single column grids
- **Tablet** (768-1024px): Sidebar navigation, 2-3 column grids
- **Desktop** (≥1024px): Full sidebar, 3-5 column grids

### Key UI Patterns
- Card-based layouts with Material 3 elevation
- Status badges with color coding
- Shimmer loading states for images
- Bottom sheets (mobile) and dialogs (desktop)
- Floating action buttons for primary actions
- Empty states with helpful messaging

## 🔧 Development Guidelines

### Adding New Features
1. **Create feature structure** following Clean Architecture:
   ```
   lib/features/new_feature/
   ├── data/
   ├── domain/ 
   └── presentation/
   ```
2. **Register dependencies** in `core/di/injection_container.dart`
3. **Add routes** in `core/navigation/app_router.dart` 
4. **Follow BLoC pattern** for state management
5. **Use Freezed** for data classes with `@freezed` annotation

### Working with Database
- **Local-first**: Always read from SQLite for instant responses
- **Sync queue**: Track changes for future Firebase sync
- **Migrations**: Handle schema changes in `DatabaseHelper`
- **Cross-platform**: Use sqflite_common_ffi for desktop support

### Code Generation Workflow
When modifying models with `@freezed` or `@JsonSerializable`:
```bash
# One-time build
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch mode during development
flutter packages pub run build_runner watch
```

### Testing Strategy
- **Unit tests**: Business logic and use cases
- **Widget tests**: Individual screen components  
- **Integration tests**: Complete user workflows
- **Golden tests**: UI consistency across platforms

## 🚨 Common Issues & Solutions

### Build Issues
```bash
# Generic build problems
flutter clean && flutter pub get

# iOS pod issues
cd ios && pod install && cd ..

# Android gradle issues  
cd android && ./gradlew clean && cd ..
```

### Database Issues
- **Web platform**: Uses mock data sources (SQLite not available)
- **Desktop platforms**: Requires sqflite_common_ffi initialization
- **Migration errors**: Check DatabaseHelper schema versions

### Hot Reload Issues
- Restart app when changing:
  - Dependencies in pubspec.yaml
  - Generated files (.freezed.dart, .g.dart)
  - Main app configuration
- Use `r` for hot reload, `R` for hot restart in terminal

## 📊 Performance Considerations

### Database Optimization
- SQLite queries use proper indexing
- Lazy loading for large datasets
- Connection pooling for concurrent operations
- Batch operations for sync queue

### UI Performance  
- Image caching with `cached_network_image`
- Shimmer placeholders during loading
- Efficient list rendering with `ListView.builder`
- Proper widget disposal in stateful components

### Memory Management
- BLoC disposal handled by flutter_bloc
- Database connections properly closed
- Image cache size limits configured
- Stream subscriptions cancelled appropriately

## 🔄 Firebase Integration (Future)

The app is structured for Firebase integration:
- Firestore collections mirror SQLite schema
- Sync service ready for background operation
- Conflict resolution strategy defined
- Network connectivity monitoring implemented

## 📚 Key Documentation Files

- `FINAL_STATUS.md` - Complete feature implementation status
- `QUICKSTART.md` - Getting started guide  
- `OFFLINE_FIRST_GUIDE.md` - Database architecture details
- `QUICK_REFERENCE.md` - Command reference and project stats

## 🎯 Production Deployment

### Pre-deployment Checklist
- [ ] `flutter analyze` shows 0 issues
- [ ] All tests pass: `flutter test` 
- [ ] Production builds successful for target platforms
- [ ] Database migrations tested
- [ ] Firebase configuration completed (when ready)
- [ ] App icons and metadata configured
- [ ] Performance profiling completed

### Platform-Specific Notes
- **Web**: Hosted on Firebase Hosting or similar
- **iOS**: Requires Apple Developer account and certificates
- **Android**: Requires signed APK/AAB with Play Console
- **Desktop**: Consider code signing for distribution

---

This codebase represents a production-ready, cross-platform POS system built with Flutter's best practices and modern architecture patterns. The offline-first design ensures reliability, while the clean architecture enables maintainability and testability.