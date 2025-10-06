# Adding Navigation to Add-on Management Screen

## Option 1: Add to Menu Editor Screen

If you have a menu editor screen that shows the list of menu items, add a button to access add-on management:

```dart
// In your menu editor screen (e.g., menu_editor_screen.dart)
import 'package:flutter/material.dart';
import 'features/pos/presentation/screens/addon_management/addon_categories_screen.dart';

class MenuEditorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Editor'),
        actions: [
          // Add this button
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Manage Add-on Categories',
            onPressed: () {
              Navigator.of(context).push(
                AddonCategoriesScreen.route(),
              );
            },
          ),
        ],
      ),
      body: YourMenuList(),
      // Or add as a FloatingActionButton
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            AddonCategoriesScreen.route(),
          );
        },
        icon: const Icon(Icons.category),
        label: const Text('Add-on Sets'),
      ),
    );
  }
}
```

## Option 2: Add to Settings/Admin Screen

Add a menu tile in your settings or admin section:

```dart
// In your settings screen
ListTile(
  leading: Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(
      Icons.category,
      color: Colors.blue.shade700,
    ),
  ),
  title: const Text('Add-on Categories'),
  subtitle: const Text('Manage reusable add-on sets'),
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () {
    Navigator.of(context).push(
      AddonCategoriesScreen.route(),
    );
  },
),
```

## Option 3: Add to Navigation Drawer

If you have a drawer menu:

```dart
// In your drawer
Drawer(
  child: ListView(
    children: [
      // ... other menu items
      ListTile(
        leading: const Icon(Icons.category),
        title: const Text('Add-on Categories'),
        onTap: () {
          Navigator.pop(context); // Close drawer
          Navigator.of(context).push(
            AddonCategoriesScreen.route(),
          );
        },
      ),
    ],
  ),
)
```

## Option 4: Add to Bottom Navigation

If you use bottom navigation:

```dart
BottomNavigationBar(
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.restaurant_menu),
      label: 'Menu',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.category),
      label: 'Add-ons',
    ),
    // ... other items
  ],
  onTap: (index) {
    if (index == 1) {
      Navigator.of(context).push(
        AddonCategoriesScreen.route(),
      );
    }
  },
)
```

## Option 5: Direct Link from Step 2

Add a helper button in Step 2 of the wizard:

```dart
// In step2_sizes_addons.dart
TextButton.icon(
  onPressed: () {
    Navigator.of(context).push(
      AddonCategoriesScreen.route(),
    );
  },
  icon: const Icon(Icons.settings),
  label: const Text('Manage Categories'),
  style: TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
)
```

## Quick Test

After adding navigation, test it:

1. Run your app
2. Navigate to the button/menu you added
3. Tap to open Add-on Categories screen
4. Click "New Category" to create your first category
5. Add items (e.g., "Cheese Options" with "Cheddar", "Swiss")
6. Go back to wizard Step 2 and attach the category to a size

## Example: Complete Menu Editor Screen

Here's a complete example with addon management button:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/pos/presentation/screens/addon_management/addon_categories_screen.dart';
import 'features/pos/presentation/screens/menu_item_wizard/menu_item_wizard_screen.dart';

class MenuEditorScreen extends StatelessWidget {
  const MenuEditorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Editor'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Add-on Management Button
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                AddonCategoriesScreen.route(),
              );
            },
            icon: const Icon(Icons.category),
            label: const Text('Add-on Sets'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Menu Items',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MenuItemWizardScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Item'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Quick Access Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.category, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Add-on Categories',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        Text(
                          'Create reusable add-on sets for your menu items',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        AddonCategoriesScreen.route(),
                      );
                    },
                    child: const Text('Open'),
                  ),
                ],
              ),
            ),
            
            // Your menu items list here
            // ...
          ],
        ),
      ),
    );
  }
}
```

## 🎉 That's It!

Once you add any of these navigation options, users can access the standalone Add-on Categories management screen to create and manage categories that can be reused across all menu items.

Choose the option that best fits your app's navigation structure!
