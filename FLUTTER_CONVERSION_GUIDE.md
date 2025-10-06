# OZPOS React to Flutter Conversion Guide

## Overview
This document outlines the complete conversion of the OZPOS React/TypeScript application to Flutter/Dart for cross-platform deployment (iOS, Android, Web, Desktop).

## ✅ Completed So Far

### 1. **Project Setup**
- ✅ Created Flutter project structure
- ✅ Configured `pubspec.yaml` with all dependencies:
  - State Management: `provider`
  - UI Components: `flutter_svg`, `cached_network_image`, `badges`, `shimmer`
  - Charts: `fl_chart`
  - Notifications: `fluttertoast`, `flutter_local_notifications`
  - Forms: `flutter_form_builder`, `form_builder_validators`
  - PDF/Printing: `pdf`, `printing`
  - Maps: `google_maps_flutter`, `geolocator`
  - Utilities: `uuid`, `shared_preferences`, `http`, `intl`

### 2. **Data Models** (lib/models/)
- ✅ `cart_item.dart` - Cart item with OrderType enum
- ✅ `order_alert.dart` - Third-party order notifications
- ✅ `customer_details.dart` - Takeaway and Delivery details
- ✅ `menu_item.dart` - Menu items with modifiers
- ✅ `table.dart` - Restaurant tables and reservations

### 3. **Theme System** (lib/theme/)
- ✅ `app_theme.dart` - Complete theme matching React app
  - Section-specific gradients (Takeaway, Dine-in, Delivery, etc.)
  - Status indicator colors
  - Shadow styles
  - Text themes

### 4. **State Management** (lib/providers/)
- ✅ `cart_provider.dart` - Cart operations with Provider pattern

### 5. **Main App** (lib/)
- ✅ `main_new.dart` - App entry point with Provider setup

## 📋 Directory Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── cart_item.dart
│   ├── customer_details.dart
│   ├── menu_item.dart
│   ├── order_alert.dart
│   └── table.dart
├── providers/                   # State management
│   ├── cart_provider.dart
│   ├── menu_provider.dart       # TODO
│   ├── table_provider.dart      # TODO
│   └── order_provider.dart      # TODO
├── screens/                     # Main screens
│   ├── main_screen.dart         # TODO - Main navigation wrapper
│   ├── dashboard_screen.dart    # TODO
│   ├── menu_screen.dart         # TODO
│   ├── checkout_screen.dart     # TODO
│   ├── tables_screen.dart       # TODO
│   ├── delivery_screen.dart     # TODO
│   ├── reports_screen.dart      # TODO
│   └── settings_screen.dart     # TODO
├── widgets/                     # Reusable widgets
│   ├── common/
│   │   ├── gradient_card.dart   # TODO
│   │   ├── status_badge.dart    # TODO
│   │   └── custom_button.dart   # TODO
│   ├── navigation/
│   │   ├── top_navigation.dart  # TODO
│   │   ├── left_sidebar.dart    # TODO
│   │   └── bottom_nav.dart      # TODO
│   ├── cart/
│   │   ├── order_summary.dart   # TODO
│   │   └── cart_item_card.dart  # TODO
│   └── menu/
│       ├── menu_item_card.dart  # TODO
│       ├── category_tabs.dart   # TODO
│       └── modifier_dialog.dart # TODO
├── theme/
│   └── app_theme.dart
├── services/                    # Business logic & API
│   ├── api_service.dart         # TODO
│   ├── print_service.dart       # TODO
│   └── storage_service.dart     # TODO
└── utils/                       # Helper functions
    ├── formatters.dart          # TODO
    ├── validators.dart          # TODO
    └── constants.dart           # TODO
```

## 🎯 Screen Conversion Mapping

### React → Flutter Screen Mapping

| React Component | Flutter Screen | Status | Priority |
|----------------|---------------|--------|----------|
| `DashboardScreen` | `dashboard_screen.dart` | TODO | HIGH |
| `MenuScreen` | `menu_screen.dart` | TODO | HIGH |
| `UnifiedCheckoutScreen` | `checkout_screen.dart` | TODO | HIGH |
| `OrderSummary` | `widgets/cart/order_summary.dart` | TODO | HIGH |
| `TablesScreen` | `tables_screen.dart` | TODO | MEDIUM |
| `DeliveryManagerScreen` | `delivery_screen.dart` | TODO | MEDIUM |
| `ReportsScreen` | `reports_screen.dart` | TODO | MEDIUM |
| `SettingsScreen` | `settings_screen.dart` | TODO | LOW |
| `MenuEditorScreen` | `menu_editor_screen.dart` | TODO | LOW |
| `DocketDesignerScreen` | `docket_designer_screen.dart` | TODO | LOW |

## 🔧 Key Implementation Patterns

### 1. **State Management with Provider**

```dart
// Access cart in any widget
final cart = Provider.of<CartProvider>(context);
final cartItems = cart.cartItems;

// Or using Consumer for reactive updates
Consumer<CartProvider>(
  builder: (context, cart, child) {
    return Text('Items: ${cart.itemCount}');
  },
)
```

### 2. **Navigation Pattern**

```dart
// Navigate to screen
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => MenuScreen()),
);

// Pop back
Navigator.of(context).pop();
```

### 3. **Gradient Containers (Matching React)**

```dart
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.takeawayGradient,
    borderRadius: BorderRadius.circular(16),
  ),
  child: YourWidget(),
)
```

### 4. **Toast Notifications (Replacing React toast)**

```dart
Fluttertoast.showToast(
  msg: "Item added to cart",
  backgroundColor: Colors.green,
  textColor: Colors.white,
);
```

### 5. **Responsive Grid (Matching MenuGrid)**

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithResponsiveColumnCount(
    crossAxisCount: _getColumnCount(context),
    crossAxisSpacing: 24,
    mainAxisSpacing: 24,
  ),
  itemBuilder: (context, index) => MenuItemCard(item: items[index]),
)

int _getColumnCount(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 1280) return 4; // xl
  if (width >= 1024) return 3; // lg
  if (width >= 640) return 2;  // sm
  return 1;
}
```

## 🎨 Component Conversion Examples

### Example 1: Menu Item Card

**React (MenuItemCard.tsx)**
```tsx
<div className="bg-white rounded-lg shadow-md overflow-hidden cursor-pointer
                hover:shadow-xl transition-all duration-200 hover:scale-105">
  <img src={item.image} alt={item.name} className="w-full h-48 object-cover" />
  <div className="p-4">
    <h3 className="font-semibold text-lg">{item.name}</h3>
    <p className="text-gray-600 text-sm">{item.description}</p>
    <p className="text-xl font-bold text-blue-600">${item.price}</p>
  </div>
</div>
```

**Flutter (menu_item_card.dart)**
```dart
class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const MenuItemCard({required this.item, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: item.image,
                height: 192,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Example 2: Gradient Dashboard Tile

**React**
```tsx
<div className="bg-gradient-to-br from-orange-500 to-amber-500 
                rounded-2xl p-8 text-white cursor-pointer
                hover:scale-105 transition-transform shadow-xl">
  <Icon className="w-12 h-12 mb-4" />
  <h3 className="text-2xl font-bold">Takeaway</h3>
  <p className="text-white/80">Manage takeaway orders</p>
</div>
```

**Flutter**
```dart
class DashboardTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const DashboardTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.elevatedShadow,
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🚀 Next Steps

### Phase 1: Core Navigation & Dashboard (Days 1-2)
1. Create `main_screen.dart` with drawer/sidebar navigation
2. Implement `dashboard_screen.dart` with gradient tiles
3. Build `top_navigation.dart` and `left_sidebar.dart` widgets

### Phase 2: Menu & Ordering (Days 3-5)
1. Build `menu_screen.dart` with category tabs
2. Create `menu_item_card.dart` widget
3. Implement modifier/customization dialog
4. Build `order_summary.dart` cart widget

### Phase 3: Checkout & Payment (Days 6-7)
1. Create `checkout_screen.dart` (unified checkout)
2. Implement payment methods UI
3. Add split bill functionality
4. Build receipt generation

### Phase 4: Tables & Reservations (Days 8-9)
1. Create `tables_screen.dart` with table grid
2. Implement reservation system
3. Add table operations (move, merge, split)

### Phase 5: Delivery Management (Day 10)
1. Build `delivery_screen.dart` with three columns
2. Integrate Google Maps for tracking
3. Add driver management

### Phase 6: Additional Features (Days 11-14)
1. Reports screen with charts (fl_chart)
2. Settings and configuration
3. Menu editor
4. Docket designer (drag-and-drop)
5. Printer integration

## 📱 Platform-Specific Considerations

### Mobile (iOS/Android)
- Use bottom navigation bar instead of left sidebar
- Optimize touch targets (minimum 44x44 points)
- Handle safe areas properly
- Use native date/time pickers

### Tablet
- Use split-view layouts where appropriate
- Maintain sidebar on larger screens
- Optimize for landscape orientation

### Web
- Full desktop layout with sidebar
- Support keyboard shortcuts
- Handle mouse hover states
- Responsive breakpoints matching original

### Desktop (macOS/Windows/Linux)
- Native window controls
- Menu bar integration
- File system access for reports
- Print dialog integration

## 🔨 Running the App

```bash
# Fetch dependencies
cd ozpos_flutter
flutter pub get

# Run on specific platform
flutter run -d chrome       # Web
flutter run -d macos        # macOS
flutter run                 # Default device

# Build for production
flutter build apk           # Android
flutter build ios           # iOS
flutter build web           # Web
flutter build macos         # macOS
```

## 📝 Notes

- **State Management**: Using Provider for simplicity. Can migrate to Riverpod for more complex needs.
- **Responsive Design**: MediaQuery and LayoutBuilder used for breakpoints.
- **Assets**: Copy all images from React app to `assets/images/`
- **API Integration**: Create service layer in `lib/services/`
- **Testing**: Add unit tests in `test/` directory

## 🐛 Known Challenges

1. **Drag-and-drop** for docket designer - Use `flutter_reorderable_grid_view`
2. **PDF generation** - Different approach than browser-based
3. **Print integration** - Platform-specific implementations needed
4. **Maps** - Requires API keys for each platform

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

---

**Last Updated**: Current session
**Status**: Foundation Complete - Ready for Screen Development
