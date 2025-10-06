# 🧭 Navigation Architecture - Professional Implementation

## Overview

Yeh document OZPOS Flutter app ki **professional senior-level navigation architecture** explain karta hai. All navigation ab **consistent** aur **maintainable** hai.

---

## 🏗️ Architecture Components

### 1. **NavigationService** (Context-Free Navigation)

`lib/core/services/navigation_service.dart`

**Purpose:** GlobalKey ke through context-free navigation provide karta hai.

```dart
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Navigate to any route without context
  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {...}
  static void pop<T>([T? result]) {...}
  static Future<T?> replace<T>(String routeName) {...}
  
  // Utility methods
  static void showSnackBar(String message) {...}
  static void showSuccess(String message) {...}
  static void showError(String message) {...}
}
```

**Benefits:**
- ✅ No context needed for navigation
- ✅ Navigate from anywhere (BLoCs, repositories, etc.)
- ✅ Centralized snackbar/dialog management
- ✅ Easy testing and mocking

---

### 2. **AppRouter** (Centralized Route Management)

`lib/core/navigation/app_router.dart`

**Purpose:** Saari app routes ko ek jagah define karta hai.

```dart
class AppRouter {
  // Route Names
  static const String dashboard = '/';
  static const String menu = '/menu';
  static const String checkout = '/checkout';
  static const String menuItemWizard = '/menu-item-wizard';
  static const String addonManagement = '/addon-management';
  // ... all routes
  
  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    
    switch (settings.name) {
      case menu:
        return MaterialPageRoute(
          builder: (_) => MenuScreenNew(
            orderType: args?['orderType'] as String?,
          ),
        );
      // ... handle all routes
    }
  }
}
```

**Benefits:**
- ✅ All routes centralized
- ✅ Type-safe argument passing
- ✅ Easy to add new routes
- ✅ Proper error handling (404 screen)

---

### 3. **Main App Setup**

`lib/main.dart`

```dart
MaterialApp(
  navigatorKey: NavigationService.navigatorKey,  // 👈 Critical!
  onGenerateRoute: AppRouter.generateRoute,
  initialRoute: AppRouter.dashboard,
)
```

---

## 📋 Usage Examples

### Basic Navigation

```dart
// Simple navigation
NavigationService.pushNamed(AppRouter.menu);

// With arguments
NavigationService.pushNamed(
  AppRouter.menu, 
  arguments: {'orderType': 'takeaway'}
);

// Pop back
NavigationService.pop();

// Replace current route
NavigationService.replace(AppRouter.dashboard);
```

### Navigation with Return Values

```dart
// Push and wait for result
final result = await NavigationService.pushNamed<MenuItemEditEntity>(
  AppRouter.menuItemWizard,
  arguments: {
    'existingItem': item,
    'isDuplicate': false,
  },
);

if (result != null) {
  NavigationService.showSuccess('Item saved!');
}
```

### Utility Methods

```dart
// Show success message
NavigationService.showSuccess('Order placed successfully!');

// Show error message
NavigationService.showError('Failed to process payment');

// Check if can pop
if (NavigationService.canPop()) {
  NavigationService.pop();
}

// Get current route
String currentRoute = NavigationService.getCurrentLocation();
```

---

## 🔄 Migration Complete

### Before (❌ Inconsistent)

```dart
// Pattern 1: Direct push
Navigator.push(context, MaterialPageRoute(...));

// Pattern 2: Named route
Navigator.pushNamed(context, '/menu');

// Pattern 3: Custom static method
Navigator.of(context).push(AddonCategoriesScreen.route());

// Pattern 4: Different navigator access
Navigator.of(context).pushNamed(widget.route);
```

### After (✅ Consistent)

```dart
// Single consistent pattern everywhere
NavigationService.pushNamed(AppRouter.menu);
NavigationService.pushNamed(AppRouter.checkout, arguments: {...});
NavigationService.pop();
```

---

## 📍 All Routes Defined

| Route Name | Path | Screen | Arguments |
|------------|------|--------|-----------|
| `dashboard` | `/` | DashboardScreen | None |
| `menu` | `/menu` | MenuScreenNew | `orderType?: String` |
| `checkout` | `/checkout` | CheckoutScreenV2 | None (uses CartBloc) |
| `orders` | `/orders` | OrdersScreenV2 | None |
| `tables` | `/tables` | TablesScreenV2 | None |
| `delivery` | `/delivery` | DeliveryScreen | None |
| `reservations` | `/reservations` | ReservationsScreenV2 | None |
| `reports` | `/reports` | ReportsScreenV2 | None |
| `settings` | `/settings` | SettingsScreen | None |
| `menuEditor` | `/menu-editor` | MenuEditorScreenV3 | None |
| `docketDesigner` | `/docket-designer` | DocketDesignerScreen | None |
| `menuItemWizard` | `/menu-item-wizard` | MenuItemWizardScreen | `existingItem?: MenuItemEditEntity, isDuplicate: bool` |
| `moveTable` | `/move-table` | MoveTableScreen | `sourceTable: TableData` |
| `addonManagement` | `/addon-management` | AddonCategoriesScreen | None (BlocProvider in route) |

---

## 🎯 Key Changes Made

### 1. Created NavigationService ✅
- GlobalKey-based context-free navigation
- Utility methods for common operations
- Snackbar/dialog helpers

### 2. Updated AppRouter ✅
- All routes defined in one place
- Proper argument handling
- Type-safe route configuration
- BlocProvider injection where needed

### 3. Updated main.dart ✅
- Added `navigatorKey` to MaterialApp
- Configured with AppRouter

### 4. Updated All Screens ✅
- **sidebar_nav.dart**: Uses NavigationService
- **dashboard_screen.dart**: Uses NavigationService
- **menu_editor_screen_v3.dart**: Uses NavigationService
- **cart_pane.dart**: Uses NavigationService
- **tables_screen_v2.dart**: Uses NavigationService
- **addon_categories_screen.dart**: Removed static route() method

---

## 🚀 Best Practices

### ✅ DO

```dart
// Use NavigationService for all navigation
NavigationService.pushNamed(AppRouter.menu);

// Define all routes in AppRouter
static const String myNewRoute = '/my-new-route';

// Pass arguments properly
NavigationService.pushNamed(
  AppRouter.menu,
  arguments: {'key': 'value'}
);

// Use utility methods
NavigationService.showSuccess('Done!');
```

### ❌ DON'T

```dart
// Don't use Navigator.push directly
Navigator.push(context, MaterialPageRoute(...)); // ❌

// Don't create custom static route() methods
static Route route() => MaterialPageRoute(...); // ❌

// Don't hardcode route strings
Navigator.pushNamed(context, '/menu'); // ❌

// Don't use ScaffoldMessenger directly
ScaffoldMessenger.of(context).showSnackBar(...); // ❌
```

---

## 🧪 Testing Benefits

```dart
// Easy to mock NavigationService in tests
class MockNavigationService extends Mock implements NavigationService {}

// Test navigation calls
verify(() => NavigationService.pushNamed(AppRouter.menu)).called(1);
```

---

## 🔮 Future Enhancements

### Option 1: Go Router (Recommended for Web)
```yaml
dependencies:
  go_router: ^13.0.0
```

### Option 2: Auto Route (Code Generation)
```yaml
dependencies:
  auto_route: ^7.8.0
```

### Option 3: Route Guards
```dart
// Add authentication/authorization checks
static bool canAccess(String route) {
  // Check user permissions
  return true;
}
```

---

## 📝 Summary

**Before:**
- 🔴 4 different navigation patterns
- 🔴 Inconsistent argument passing
- 🔴 Routes scattered everywhere
- 🔴 Hard to maintain/test

**After:**
- ✅ Single consistent pattern
- ✅ Type-safe navigation
- ✅ Centralized route management
- ✅ Easy to maintain/test
- ✅ Professional senior-level architecture

---

## 🎓 Conclusion

Ab tumhari navigation **professional Flutter standards** follow kar rahi hai:

1. ✅ **Consistent** - Ek hi pattern har jagah
2. ✅ **Maintainable** - Sab kuch centralized
3. ✅ **Type-safe** - Proper argument handling
4. ✅ **Testable** - Easy to mock/test
5. ✅ **Scalable** - Easily add new routes

Yeh wahi approach hai jo **senior Flutter developers** use karte hain production apps mein! 🚀

