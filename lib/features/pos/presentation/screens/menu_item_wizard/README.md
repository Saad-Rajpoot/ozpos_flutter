# Menu Item Wizard - Quick Start

## 🚀 Overview

A comprehensive 5-step wizard for creating and editing menu items in the OZPOS Flutter app. This wizard provides an intuitive, guided experience for managing complex menu item configurations including sizes, add-ons, pricing, and availability.

## ✨ Features

### Current Implementation (Step 1 Complete)
- ✅ **Step 1: Item Details** - Fully functional
  - Image upload (URL-based for now)
  - Item name, description, SKU
  - Category selection
  - Badge management
  
- ✅ **Navigation System**
  - 5-step progress indicator
  - Back/Continue buttons
  - Step validation
  - Draft saving
  
- ✅ **Summary Sidebar**
  - Live validation feedback
  - Availability status
  - Price display
  - Error/warning list

### Coming Soon
- 🚧 **Step 2: Sizes & Add-ons** - Next priority
- 🚧 **Step 3: Upsells & Suggestions**
- 🚧 **Step 4: Availability & Settings**
- 🚧 **Step 5: Review & Save**

## 📖 Usage

### Basic Usage

```dart
import 'package:ozpos_flutter/features/pos/presentation/screens/menu_item_wizard/menu_item_wizard_screen.dart';

// Create a new menu item
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MenuItemWizardScreen(),
  ),
);
```

### Edit Existing Item

```dart
// Edit an existing menu item
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MenuItemWizardScreen(
      existingItem: existingMenuItem, // MenuItemEditEntity
    ),
  ),
);
```

### Duplicate Item

```dart
// Duplicate an existing item (clears ID and marks as new)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MenuItemWizardScreen(
      existingItem: itemToDuplicate,
      isDuplicate: true,
    ),
  ),
);
```

### Handling Result

```dart
// Get the saved item when wizard completes
final result = await Navigator.push<MenuItemEditEntity>(
  context,
  MaterialPageRoute(
    builder: (context) => const MenuItemWizardScreen(),
  ),
);

if (result != null) {
  // Item was saved successfully
  print('Saved item: ${result.name}');
}
```

## 🏗️ Architecture

### BLoC Pattern
The wizard uses the BLoC pattern for state management:

- **MenuEditBloc** - Central business logic
- **MenuEditEvent** - 20+ events for all actions
- **MenuEditState** - Immutable state with validation

### Key Components

```
menu_item_wizard/
├── menu_item_wizard_screen.dart    # Main container
├── widgets/
│   ├── wizard_stepper.dart         # Progress indicator
│   ├── wizard_nav_bar.dart         # Navigation bar
│   └── summary_sidebar.dart        # Validation sidebar
└── steps/
    ├── step1_item_details.dart     # ✅ Complete
    ├── step2_sizes_addons.dart     # 🚧 Placeholder
    ├── step3_upsells.dart          # 🚧 Placeholder
    ├── step4_availability.dart     # 🚧 Placeholder
    └── step5_review.dart           # 🚧 Placeholder
```

## 🎨 Design System

### Colors
- **Primary Blue**: `#2196F3` - Action buttons, active states
- **Success Green**: `#10B981` - Completed steps, success messages
- **Error Red**: `#EF4444` - Validation errors
- **Warning Orange**: `#F59E0B` - Warnings, draft badge

### Spacing
- Base unit: 8px
- Common values: 8, 12, 16, 24, 32, 48

### Typography
- Headings: 18-20px, weight 600
- Body: 14px, weight 400-500
- Small text: 12px

## 🧪 Testing the Wizard

### Quick Test in Existing Screen

Add this button to any screen to test the wizard:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MenuItemWizardScreen(),
      ),
    );
  },
  child: const Text('Open Menu Item Wizard'),
)
```

### Test Data

The wizard comes with mock data for testing:
- **System badges**: NEW, POPULAR, SPICY, VEGAN, GLUTEN-FREE
- **Add-on categories**: Toppings, Sauces, Sides (Step 2, coming soon)

## 📝 Development Notes

### Current Limitations
1. **Image upload** - Currently URL-based, needs proper file picker
2. **Category data** - Using hardcoded list, needs integration with actual categories
3. **Steps 2-5** - Placeholder implementations, coming soon

### Adding Real Data Sources

Replace mock data with real repositories:

```dart
// In menu_edit_bloc.dart
// Replace mock data:
final badges = mockSystemBadges;

// With repository call:
final badges = await badgeRepository.getAllBadges();
```

### Validation Rules

Current validation (in `menu_edit_state.dart`):
- Item name required
- Category required
- At least one size with price (coming in Step 2)
- Channel availability consistency

## 🐛 Troubleshooting

### "Cannot find MenuItemWizardScreen"
Make sure the import path is correct:
```dart
import 'package:ozpos_flutter/features/pos/presentation/screens/menu_item_wizard/menu_item_wizard_screen.dart';
```

### "BLoC not found in context"
The wizard creates its own BLoC provider. Don't wrap it in another BlocProvider.

### Validation errors not showing
Check that you're reading validation from state:
```dart
BlocBuilder<MenuEditBloc, MenuEditState>(
  builder: (context, state) {
    // state.validation contains errors and warnings
  },
)
```

## 🚦 Next Steps

### For Users
1. Test Step 1 functionality
2. Provide feedback on UX/design
3. Report any bugs or issues

### For Developers
1. Implement Step 2 (Sizes & Add-ons) - highest priority
2. Integrate with actual data sources
3. Add proper image picker
4. Implement Steps 3-5
5. Add unit and widget tests
6. Performance optimization

## 📚 Related Documentation

- [Full Implementation Guide](../../../../docs/menu_item_wizard_implementation_guide.md)
- [Progress Tracker](../../../../docs/menu_wizard_progress.md)
- [Domain Entities](../../../domain/entities/menu_item_edit_entity.dart)
- [BLoC Implementation](../../bloc/menu_edit_bloc.dart)

## 💡 Tips

### Draft Saving
- Click the save icon in the app bar to save as draft
- Drafts are marked with an orange badge
- Wizard warns before closing with unsaved changes

### Navigation
- Use stepper to jump between steps
- Back/Continue buttons for sequential navigation
- Validation doesn't block navigation (except on final save)

### Validation
- Real-time validation in sidebar
- Red errors prevent saving
- Orange warnings are suggestions only

## 🤝 Contributing

When adding new features:
1. Follow existing patterns from Step 1
2. Add BLoC events in `menu_edit_event.dart`
3. Update state handlers in `menu_edit_bloc.dart`
4. Update validation in `menu_edit_state.dart`
5. Add UI components in appropriate step file

## 📧 Support

For questions or issues:
1. Check the troubleshooting section above
2. Review the implementation guide
3. Check existing BLoC events and state
4. Create an issue with details and steps to reproduce
