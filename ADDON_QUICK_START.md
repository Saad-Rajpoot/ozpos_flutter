# Add-on Management System - Quick Start Guide

## 🚀 5-Minute Integration

### 1. Check Dependencies
Verify your `pubspec.yaml` has:
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  uuid: ^4.0.0
```

### 2. Wrap Your Wizard with BLoC
In `menu_item_wizard_screen.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/addon_management/addon_management_bloc.dart';
import '../bloc/addon_management/addon_management_event.dart';

class MenuItemWizardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddonManagementBloc()
        ..add(const LoadAddonCategoriesEvent()),
      child: Scaffold(
        // your existing wizard UI
      ),
    );
  }
}
```

### 3. Update Size Row Widget
In `size_row_widget.dart`, replace the addon section:

```dart
import '../../widgets/addon/addon_rules_compact_display.dart';

// In _buildExpandedView(), replace _buildAddOnsSection() with:
Widget _buildAddOnsSection() {
  // Generate a unique sizeId if not exists
  final sizeId = widget.size.id ?? const Uuid().v4();
  
  return AddonRulesCompactDisplay(
    itemId: widget.itemId,  // Pass from parent
    sizeId: sizeId,
    sizeLabel: widget.size.name,
  );
}
```

### 4. Pass itemId to SizeRowWidget
In `step2_sizes_addons.dart`, update the widget call:

```dart
SizeRowWidget(
  size: size,
  itemId: state.menuItem.id ?? 'temp_id', // Your menu item ID
  // ... other props
)
```

### 5. Test It!
Run your app and:
1. Go to menu item wizard → Step 2
2. Click "Add Set" in any size row
3. Select a category (Cheese, Sauces, or Toppings)
4. Configure items and rules
5. Save and see the blue panels with your selections!

## 📦 What You Get Out of the Box

### Pre-loaded Categories
1. **Cheese Options** (4 items)
   - Cheddar ($1.50)
   - Swiss ($2.00)
   - Mozzarella ($1.75)
   - Blue Cheese ($2.50)

2. **Sauces** (4 items)
   - BBQ Sauce ($0.50)
   - Mayo ($0.30)
   - Mustard ($0.30)
   - Hot Sauce ($0.50)

3. **Extra Toppings** (5 items)
   - Bacon ($2.00)
   - Avocado ($1.50)
   - Mushrooms ($1.00)
   - Grilled Onions ($0.75)
   - Jalapeños ($0.75)

## 🎯 Common Use Cases

### Attach Add-ons to All Sizes
```dart
// User clicks "Add Set" on any size
// System attaches to item-level (appliesToAllSizes = true)
// All sizes inherit these rules automatically
```

### Override for Specific Size
```dart
// User clicks "Add Set" on "Large" size
// System creates size-specific rules
// Other sizes still use item-level rules
// "Overridden" badge appears on Large
```

### Price Override Example
```dart
// Base: Swiss Cheese = $2.00
// Large size only: Override to $3.00
// Shows: $2.00 → $3.00 with strikethrough
```

### Validation Example
```dart
// Set: Min=2, Max=1 (invalid!)
// System shows red error: "Minimum selection (2) cannot exceed maximum (1)"
// Save button disabled until fixed
```

## 🔧 Customization

### Add Your Own Categories
In `addon_management_bloc.dart`, edit `_getMockCategories()`:

```dart
AddonCategory(
  id: 'cat_drinks',
  name: 'Beverages',
  description: 'Add a drink',
  items: [
    const AddonItem(
      id: 'drink_coke',
      name: 'Coca-Cola',
      basePriceDelta: 2.50,
    ),
    // ... more items
  ],
  createdAt: now,
  updatedAt: now,
)
```

### Change Colors
Search and replace in widget files:
- Blue theme: `Colors.blue.shade50` → your primary color
- Orange overrides: `Colors.orange.shade50` → your secondary color
- Red errors: `Colors.red.shade50` → your error color

### Adjust Validation Rules
In `addon_management_entities.dart`, `AddonRule.validate()`:

```dart
// Example: Allow negative prices for discounts
if (priceOverrides[itemId]! < -10) {
  errors.add('Discount cannot exceed -$10');
}
```

## 📱 UI Flow

### Category Picker (Bottom Sheet)
1. User clicks "Add Set"
2. Sheet slides up with all categories
3. Search bar filters instantly
4. Click category to attach
5. Sheet dismisses, shows success snackbar

### Item Selector (Dialog)
1. User clicks "Edit" on blue panel
2. Full-screen dialog opens
3. Checkboxes for each item
4. Min/Max/Required at top in blue box
5. Price icons to override individual prices
6. Running total at top
7. Save/Cancel at bottom

### Compact Display (Step 2)
1. Blue expansion panels show attached categories
2. Click to expand → see selected items as chips
3. "Overridden" badge if size-specific
4. "Reset to Item-Level" button appears
5. Edit icon opens item selector

## ⚡ Performance Tips

- Categories load once on wizard open
- Rules computed on-demand (getEffectiveRules)
- Validation runs only on rule changes
- UI rebuilds scoped to BlocBuilder widgets

## 🐛 Troubleshooting

### "BLoC not found in context"
**Solution**: Ensure BlocProvider wraps the widget tree above where you're using the addon widgets.

### "itemId is null"
**Solution**: Pass the menu item ID from your wizard state/BLoC to the size row widget.

### "No categories showing"
**Solution**: Check that `LoadAddonCategoriesEvent` is dispatched after BLoC creation.

### "Changes not saving"
**Solution**: Implement persistence layer - currently only in-memory. See `ADDON_MANAGEMENT_IMPLEMENTATION.md` Step 5.

### "Size rules not working"
**Solution**: Ensure each size has a unique ID (use UUID or database ID).

## 📚 API Reference

### Events
```dart
// Load categories
LoadAddonCategoriesEvent()

// Attach category
AttachAddonCategoryEvent(itemId: '', sizeId: null, categoryId: '')

// Toggle item selection
ToggleAddonItemSelectionEvent(itemId: '', sizeId: null, categoryId: '', addonItemId: '')

// Override price
OverrideAddonItemPriceEvent(itemId: '', categoryId: '', addonItemId: '', overridePrice: 3.0)

// Update rules
UpdateSelectionRulesEvent(itemId: '', categoryId: '', minSelection: 0, maxSelection: 2, isRequired: false)

// Validate
ValidateAddonRulesEvent(itemId: '')

// Reset size rules
ResetSizeRulesToItemLevelEvent(itemId: '', sizeId: '')

// Duplicate
DuplicateRulesToSizeEvent(itemId: '', sourceSizeId: '', targetSizeId: '')
```

### State Getters
```dart
final state = context.read<AddonManagementBloc>().state as AddonManagementLoaded;

// Get effective rules for a size
final rules = state.getEffectiveRules(itemId, sizeId);

// Get selected addons with prices
final addons = state.getSelectedAddons(itemId, sizeId);

// Check if valid
final isValid = state.isItemValid(itemId);

// Get error count
final errors = state.getErrorCount(itemId);
```

## 🎉 You're Ready!

Follow the 5-step integration above and you'll have a fully functional add-on management system running in minutes.

For detailed architecture and advanced features, see `ADDON_MANAGEMENT_IMPLEMENTATION.md`.

**Happy Coding! 🚀**
