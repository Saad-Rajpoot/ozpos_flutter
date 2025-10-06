# Menu Editor Wizard - Complete Implementation Guide

## 📋 Overview

This document provides a complete implementation plan for the 5-step menu item editing wizard that matches the React prototype exactly. The wizard allows restaurant owners to create and edit menu items with sizes, add-ons, pricing, availability, and live POS preview.

**Total Estimated Lines**: ~5,000+ lines across multiple files
**Estimated Time**: 4-5 days for full implementation
**Architecture**: Clean Architecture with BLoC pattern

---

## 🎯 Requirements Summary

### Visual Parity
- ✅ Match screenshots exactly (spacing, colors, chips, radii)
- ✅ 5-step wizard with progress indicator
- ✅ Right sidebar with live summary
- ✅ Unsaved changes pill
- ✅ POS modifier preview in Step 5

### Functional Requirements
- ✅ Size-based add-on configuration
- ✅ Per-channel pricing with inheritance
- ✅ Upsells and related items
- ✅ Live validation
- ✅ Draft saving
- ✅ Duplicate functionality

---

## 📁 File Structure

```
lib/features/pos/
├── domain/entities/
│   └── menu_item_edit_entity.dart ✅ CREATED (239 lines)
├── presentation/
│   ├── bloc/
│   │   ├── menu_edit_bloc.dart          [TODO - 400 lines]
│   │   ├── menu_edit_event.dart         [TODO - 150 lines]
│   │   └── menu_edit_state.dart         [TODO - 100 lines]
│   ├── screens/
│   │   └── menu_item_wizard/
│   │       ├── menu_item_wizard_screen.dart  [TODO - 600 lines]
│   │       ├── steps/
│   │       │   ├── step_1_item_details.dart         [TODO - 400 lines]
│   │       │   ├── step_2_sizes_addons.dart         [TODO - 700 lines]
│   │       │   ├── step_3_upsells.dart              [TODO - 400 lines]
│   │       │   ├── step_4_pricing_availability.dart [TODO - 350 lines]
│   │       │   └── step_5_review.dart               [TODO - 600 lines]
│   │       └── widgets/
│   │           ├── wizard_stepper.dart              [TODO - 150 lines]
│   │           ├── summary_sidebar.dart             [TODO - 250 lines]
│   │           ├── size_row_expanded.dart           [TODO - 400 lines]
│   │           ├── category_item_selector_dialog.dart [TODO - 350 lines]
│   │           ├── badge_selector.dart              [TODO - 200 lines]
│   │           ├── badge_manager_dialog.dart        [TODO - 300 lines]
│   │           └── pos_modifier_preview.dart        [TODO - 350 lines]
└── data/
    └── mock/
        ├── mock_addon_categories.dart   [TODO - 200 lines]
        └── mock_system_badges.dart      [TODO - 100 lines]
```

**Total Files**: 17 files
**Total Lines**: ~5,250 lines

---

## 🏗️ Implementation Phases

### Phase 1: Foundation (Day 1 - Morning)

#### 1.1 Mock Data
**File**: `lib/features/pos/data/mock/mock_addon_categories.dart`

```dart
// Mock add-on categories for testing
const mockAddOnCategories = [
  AddOnCategoryEntity(
    id: 'cheese-options',
    name: 'Cheese Options',
    description: 'Choose your cheese',
    items: [
      AddOnOptionEntity(id: 'cheese-cheddar', name: 'Cheddar Cheese', basePrice: 1.50),
      AddOnOptionEntity(id: 'cheese-mozzarella', name: 'Mozzarella', basePrice: 1.50),
      AddOnOptionEntity(id: 'cheese-parmesan', name: 'Parmesan', basePrice: 1.75),
      AddOnOptionEntity(id: 'cheese-swiss', name: 'Swiss Cheese', basePrice: 1.75),
      AddOnOptionEntity(id: 'cheese-blue', name: 'Blue Cheese', basePrice: 2.00),
    ],
  ),
  // ... more categories
];
```

**File**: `lib/features/pos/data/mock/mock_system_badges.dart`

```dart
const systemBadges = [
  BadgeEntity(id: 'vegetarian', label: 'Vegetarian', color: '#10B981', icon: '🌱', isSystem: true),
  BadgeEntity(id: 'vegan', label: 'Vegan', color: '#059669', icon: '🥬', isSystem: true),
  BadgeEntity(id: 'spicy', label: 'Spicy', color: '#EF4444', icon: '🌶️', isSystem: true),
  BadgeEntity(id: 'popular', label: 'Popular', color: '#F59E0B', icon: '⭐', isSystem: true),
  BadgeEntity(id: 'gluten-free', label: 'Gluten-Free', color: '#8B5CF6', icon: '🌾', isSystem: true),
  // ... more badges
];
```

#### 1.2 BLoC Setup
**File**: `lib/features/pos/presentation/bloc/menu_edit_event.dart`

```dart
abstract class MenuEditEvent {}

class InitializeMenuEdit extends MenuEditEvent {
  final MenuItemEditEntity? existingItem;
}

class UpdateItemName extends MenuEditEvent {
  final String name;
}

class UpdateItemDescription extends MenuEditEvent {
  final String description;
}

class UpdateItemCategory extends MenuEditEvent {
  final String category;
}

class ToggleBadge extends MenuEditEvent {
  final String badgeId;
}

class SetHasSizes extends MenuEditEvent {
  final bool hasSizes;
}

class AddSize extends MenuEditEvent {}

class UpdateSize extends MenuEditEvent {
  final int index;
  final SizeEditEntity size;
}

class DeleteSize extends MenuEditEvent {
  final int index;
}

class SetDefaultSize extends MenuEditEvent {
  final int index;
}

class AddAddOnItemToSize extends MenuEditEvent {
  final int sizeIndex;
  final AddOnItemEditEntity addOnItem;
}

class RemoveAddOnItemFromSize extends MenuEditEvent {
  final int sizeIndex;
  final String itemId;
}

class UpdateAddOnItemPrice extends MenuEditEvent {
  final int sizeIndex;
  final String itemId;
  final double price;
}

class AddUpsellItem extends MenuEditEvent {
  final String itemId;
}

class RemoveUpsellItem extends MenuEditEvent {
  final String itemId;
}

class AddRelatedItem extends MenuEditEvent {
  final String itemId;
}

class RemoveRelatedItem extends MenuEditEvent {
  final String itemId;
}

class UpdateAvailability extends MenuEditEvent {
  final bool? posAvailable;
  final bool? onlineAvailable;
  final bool? deliveryAvailable;
}

class SaveDraft extends MenuEditEvent {}

class SaveItem extends MenuEditEvent {}

class DuplicateItem extends MenuEditEvent {}
```

**File**: `lib/features/pos/presentation/bloc/menu_edit_state.dart`

```dart
enum MenuEditStatus { initial, editing, saving, saved, error }

class MenuEditState {
  final MenuEditStatus status;
  final MenuItemEditEntity item;
  final ValidationResult validation;
  final int currentStep;
  final bool hasUnsavedChanges;
  final String? errorMessage;

  const MenuEditState({
    required this.status,
    required this.item,
    required this.validation,
    required this.currentStep,
    required this.hasUnsavedChanges,
    this.errorMessage,
  });

  factory MenuEditState.initial() {
    return MenuEditState(
      status: MenuEditStatus.initial,
      item: MenuItemEditEntity.empty(),
      validation: const ValidationResult(errors: [], warnings: []),
      currentStep: 1,
      hasUnsavedChanges: false,
    );
  }

  MenuEditState copyWith({
    MenuEditStatus? status,
    MenuItemEditEntity? item,
    ValidationResult? validation,
    int? currentStep,
    bool? hasUnsavedChanges,
    String? errorMessage,
  }) {
    return MenuEditState(
      status: status ?? this.status,
      item: item ?? this.item,
      validation: validation ?? this.validation,
      currentStep: currentStep ?? this.currentStep,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
```

**File**: `lib/features/pos/presentation/bloc/menu_edit_bloc.dart`

```dart
class MenuEditBloc extends Bloc<MenuEditEvent, MenuEditState> {
  MenuEditBloc() : super(MenuEditState.initial()) {
    on<InitializeMenuEdit>(_onInitialize);
    on<UpdateItemName>(_onUpdateName);
    on<UpdateItemDescription>(_onUpdateDescription);
    on<UpdateItemCategory>(_onUpdateCategory);
    on<ToggleBadge>(_onToggleBadge);
    on<SetHasSizes>(_onSetHasSizes);
    on<AddSize>(_onAddSize);
    on<UpdateSize>(_onUpdateSize);
    on<DeleteSize>(_onDeleteSize);
    on<SetDefaultSize>(_onSetDefaultSize);
    on<AddAddOnItemToSize>(_onAddAddOnItemToSize);
    on<RemoveAddOnItemFromSize>(_onRemoveAddOnItemFromSize);
    on<UpdateAddOnItemPrice>(_onUpdateAddOnItemPrice);
    on<AddUpsellItem>(_onAddUpsellItem);
    on<RemoveUpsellItem>(_onRemoveUpsellItem);
    on<AddRelatedItem>(_onAddRelatedItem);
    on<RemoveRelatedItem>(_onRemoveRelatedItem);
    on<UpdateAvailability>(_onUpdateAvailability);
    on<SaveDraft>(_onSaveDraft);
    on<SaveItem>(_onSaveItem);
    on<DuplicateItem>(_onDuplicateItem);
  }

  void _onInitialize(InitializeMenuEdit event, Emitter<MenuEditState> emit) {
    final item = event.existingItem ?? MenuItemEditEntity.empty();
    final validation = _validateItem(item);
    
    emit(state.copyWith(
      item: item,
      validation: validation,
      hasUnsavedChanges: false,
    ));
  }

  void _onUpdateName(UpdateItemName event, Emitter<MenuEditState> emit) {
    final updatedItem = state.item.copyWith(name: event.name);
    final validation = _validateItem(updatedItem);
    
    emit(state.copyWith(
      item: updatedItem,
      validation: validation,
      hasUnsavedChanges: true,
    ));
  }

  // ... more event handlers

  ValidationResult _validateItem(MenuItemEditEntity item) {
    final errors = <String>[];
    final warnings = <String>[];

    if (item.name.trim().isEmpty) {
      errors.add('Item name is required');
    }

    if (item.category.isEmpty) {
      errors.add('Category must be selected');
    }

    if (item.hasSizes && item.sizes.isEmpty) {
      errors.add('Add at least one size');
    }

    if (!item.hasSizes && item.basePrice <= 0) {
      errors.add('Base price must be greater than zero');
    }

    if (item.hasSizes) {
      final defaultSizes = item.sizes.where((s) => s.isDefault).length;
      if (defaultSizes == 0) {
        errors.add('One size must be marked as default');
      } else if (defaultSizes > 1) {
        errors.add('Only one size can be default');
      }
    }

    if (!item.posAvailable && !item.onlineAvailable && !item.deliveryAvailable) {
      errors.add('Item must be available on at least one channel');
    }

    return ValidationResult(errors: errors, warnings: warnings);
  }
}
```

---

### Phase 2: Step 1 - Item Details (Day 1 - Afternoon)

**File**: `lib/features/pos/presentation/screens/menu_item_wizard/steps/step_1_item_details.dart`

```dart
class Step1ItemDetails extends StatelessWidget {
  const Step1ItemDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuEditBloc, MenuEditState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Section
              _buildImageUpload(context, state),
              const SizedBox(height: 24),

              // Item Name
              _buildItemName(context, state),
              const SizedBox(height: 20),

              // Description
              _buildDescription(context, state),
              const SizedBox(height: 20),

              // Category
              _buildCategory(context, state),
              const SizedBox(height: 24),

              // Badges
              BadgeSelector(
                availableBadges: systemBadges,
                selectedBadgeIds: state.item.badgeIds,
                onBadgeToggle: (badgeId) {
                  context.read<MenuEditBloc>().add(ToggleBadge(badgeId));
                },
                onManageBadges: () {
                  // Show badge manager dialog
                  showDialog(
                    context: context,
                    builder: (_) => const BadgeManagerDialog(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Info Box
              _buildInfoBox(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageUpload(BuildContext context, MenuEditState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Image',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: InkWell(
            onTap: () {
              // Handle image upload
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Drag & drop an image or click to browse',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recommended: 400x400px, JPG or PNG',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemName(BuildContext context, MenuEditState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Item Name', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: state.item.name),
          onChanged: (value) {
            context.read<MenuEditBloc>().add(UpdateItemName(value));
          },
          decoration: const InputDecoration(
            hintText: 'e.g. Classic Burger',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // ... more build methods
}
```

---

### Phase 3: Step 2 - Sizes & Add-ons (Day 2)

This is the most complex step with inline add-on configuration.

**File**: `lib/features/pos/presentation/screens/menu_item_wizard/steps/step_2_sizes_addons.dart`

Key features:
- Toggle for "This item has sizes"
- Size preset buttons (Burger sizes, Pizza sizes)
- Size table header
- Expandable size rows with `SizeRowExpanded` widget
- Add Size button
- Info box explaining inline configuration

**File**: `lib/features/pos/presentation/screens/menu_item_wizard/widgets/size_row_expanded.dart`

```dart
class SizeRowExpanded extends StatefulWidget {
  final SizeEditEntity size;
  final int index;
  final List<AddOnCategoryEntity> availableCategories;
  final Function(String field, dynamic value) onSizeChange;
  final Function(AddOnItemEditEntity) onAddOnItemAdd;
  final Function(String itemId) onAddOnItemRemove;
  final Function(String itemId, double price) onAddOnItemPriceChange;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const SizeRowExpanded({...});

  @override
  State<SizeRowExpanded> createState() => _SizeRowExpandedState();
}

class _SizeRowExpandedState extends State<SizeRowExpanded> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Collapsed row
          _buildCollapsedRow(),
          
          // Expanded add-ons panel
          if (_isExpanded) _buildExpandedPanel(),
        ],
      ),
    );
  }

  Widget _buildCollapsedRow() {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Expand/collapse icon
            Icon(_isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right),
            const SizedBox(width: 12),
            
            // Size name input
            Expanded(
              flex: 2,
              child: TextField(
                controller: TextEditingController(text: widget.size.name),
                onChanged: (value) => widget.onSizeChange('name', value),
                decoration: const InputDecoration(
                  hintText: 'Size name',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Dine-in price
            Expanded(
              flex: 2,
              child: TextField(
                controller: TextEditingController(
                  text: widget.size.dineInPrice.toString(),
                ),
                onChanged: (value) {
                  final price = double.tryParse(value) ?? 0.0;
                  widget.onSizeChange('dineInPrice', price);
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '\$0.00',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Takeaway (Inherit option)
            Expanded(
              flex: 2,
              child: _buildInheritablePrice('takeaway', widget.size.takeawayPrice),
            ),
            const SizedBox(width: 12),
            
            // Delivery (Inherit option)
            Expanded(
              flex: 2,
              child: _buildInheritablePrice('delivery', widget.size.deliveryPrice),
            ),
            const SizedBox(width: 12),
            
            // Default checkbox
            Checkbox(
              value: widget.size.isDefault,
              onChanged: (_) => widget.onSetDefault(),
            ),
            const SizedBox(width: 12),
            
            // Add-ons count chip
            Chip(
              label: Text('${widget.size.addOnItems.length}'),
              backgroundColor: widget.size.addOnItems.isNotEmpty
                  ? Colors.blue.shade50
                  : Colors.grey.shade100,
            ),
            const SizedBox(width: 12),
            
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPanel() {
    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add-ons for ${widget.size.name}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                onPressed: _showCategoryItemSelector,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // List of configured add-ons
          if (widget.size.addOnItems.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No items added yet\nClick "Add Item" to select items from categories',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...widget.size.addOnItems.map((item) => _buildAddOnItem(item)),
        ],
      ),
    );
  }

  Widget _buildAddOnItem(AddOnItemEditEntity item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(item.categoryName, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Base price (from category)
            Text(
              'Base: \$${item.basePrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 12),
            
            // Actual price for this size
            SizedBox(
              width: 100,
              child: TextField(
                controller: TextEditingController(text: item.price.toStringAsFixed(2)),
                onChanged: (value) {
                  final price = double.tryParse(value) ?? item.basePrice;
                  widget.onAddOnItemPriceChange(item.itemId, price);
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: '\$',
                  isDense: true,
                  labelText: 'Price',
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Remove button
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => widget.onAddOnItemRemove(item.itemId),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryItemSelector() {
    showDialog(
      context: context,
      builder: (_) => CategoryItemSelectorDialog(
        availableCategories: widget.availableCategories,
        alreadySelectedIds: widget.size.addOnItems.map((e) => e.itemId).toList(),
        onItemsSelected: (items) {
          for (final item in items) {
            widget.onAddOnItemAdd(item);
          }
        },
      ),
    );
  }
}
```

**File**: `lib/features/pos/presentation/screens/menu_item_wizard/widgets/category_item_selector_dialog.dart`

This dialog shows categories, then items within selected categories, with checkboxes and prices.

---

### Phase 4: Steps 3-5 (Day 3)

#### Step 3: Upsells & Suggestions
- Grid of selectable menu items for upsells
- Grid of selectable menu items for related items
- Meal deals/bundles section with switches

#### Step 4: Pricing & Availability
- Pricing summary (shows per-size if hasSizes)
- Channel toggles (POS, Online, Delivery)
- Tax class dropdown
- SKU input
- Stock tracking toggle

#### Step 5: Review & Save
- **POS Modifier Popup Preview** (most important!)
  - Simulated mobile POS interface
  - Size selector buttons
  - Add-ons grouped by category
  - Total price calculation
  - Upsell suggestions at bottom
- Configuration details expandable
- Summary stats cards
- Quick edit buttons

---

### Phase 5: Main Wizard Screen (Day 4)

**File**: `lib/features/pos/presentation/screens/menu_item_wizard/menu_item_wizard_screen.dart`

Structure:
```dart
Scaffold(
  body: Row(
    children: [
      // Main content area
      Expanded(
        child: Column(
          children: [
            // Top action bar
            _buildTopBar(),
            
            // Step indicator
            WizardStepper(currentStep: state.currentStep, totalSteps: 5),
            
            // Step title and description
            _buildStepHeader(),
            
            // Step content
            Expanded(
              child: IndexedStack(
                index: state.currentStep - 1,
                children: [
                  const Step1ItemDetails(),
                  const Step2SizesAddons(),
                  const Step3Upsells(),
                  const Step4PricingAvailability(),
                  const Step5Review(),
                ],
              ),
            ),
            
            // Bottom navigation
            _buildBottomNav(),
          ],
        ),
      ),
      
      // Right sidebar (always visible)
      SummarySidebar(validation: state.validation, item: state.item),
    ],
  ),
)
```

---

## 🎨 Design Specifications

### Colors
```dart
class MenuEditorColors {
  static const primary = Color(0xFF2196F3);
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const purple = Color(0xFF8B5CF6);
  
  static const expandedPanelBg = Color(0xFFEFF6FF); // Blue-50
  static const cardBorder = Color(0xFFE5E7EB); // Gray-200
}
```

### Spacing
```dart
class MenuEditorSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}
```

### Border Radius
```dart
class MenuEditorRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const full = 999.0;
}
```

---

## ✅ Acceptance Criteria

### Visual
- [ ] Matches screenshots exactly
- [ ] Smooth animations (expand/collapse)
- [ ] Proper spacing and alignment
- [ ] Correct colors and gradients
- [ ] No text overflow at 1.1x scale

### Functional
- [ ] Can add/remove sizes
- [ ] Can add/remove add-ons per size
- [ ] Per-size price override works
- [ ] Inherit pricing works correctly
- [ ] Default size enforcement
- [ ] Validation blocks invalid states
- [ ] Unsaved changes tracking
- [ ] Draft save works
- [ ] Full save works
- [ ] Duplicate creates new draft

### Preview
- [ ] POS preview shows correct sizes
- [ ] POS preview shows correct add-ons
- [ ] POS preview calculates price correctly
- [ ] Preview updates when changing size
- [ ] Upsells show in preview

---

## 🧪 Testing Plan

### Unit Tests
```dart
test('validates item name required', () {
  final validation = validator.validate(emptyItem);
  expect(validation.errors, contains('Item name is required'));
});

test('validates default size enforcement', () {
  final item = itemWithMultipleSizes.copyWith(
    sizes: [
      size1.copyWith(isDefault: false),
      size2.copyWith(isDefault: false),
    ],
  );
  final validation = validator.validate(item);
  expect(validation.errors, contains('One size must be marked as default'));
});

test('calculates price range correctly', () {
  final item = itemWithThreeSizes;
  expect(item.minPrice, 12.99);
  expect(item.maxPrice, 18.99);
});
```

### Widget Tests
```dart
testWidgets('size row expands on tap', (tester) async {
  await tester.pumpWidget(testWidget);
  
  // Initially collapsed
  expect(find.text('Add-ons for'), findsNothing);
  
  // Tap to expand
  await tester.tap(find.byType(SizeRowExpanded));
  await tester.pumpAndSettle();
  
  // Now expanded
  expect(find.text('Add-ons for'), findsOneWidget);
});
```

### Integration Tests
```dart
testWidgets('complete item creation flow', (tester) async {
  // Step 1: Enter item details
  await tester.enterText(find.byKey(Key('itemName')), 'Test Burger');
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
  
  // Step 2: Add sizes
  await tester.tap(find.text('Add Size'));
  // ... configure sizes and add-ons
  
  // Step 3: Add upsells
  // ...
  
  // Step 4: Set availability
  // ...
  
  // Step 5: Review and save
  await tester.tap(find.text('Save Item'));
  await tester.pumpAndSettle();
  
  // Verify saved
  expect(find.text('Item saved successfully'), findsOneWidget);
});
```

---

## 📝 Implementation Checklist

### Day 1: Foundation
- [x] Create domain entities ✅
- [ ] Create mock data
- [ ] Create BLoC (events, state, bloc)
- [ ] Create Step 1: Item Details

### Day 2: Sizes & Add-ons
- [ ] Create SizeRowExpanded widget
- [ ] Create CategoryItemSelectorDialog
- [ ] Create Step 2: Sizes & Add-ons
- [ ] Test size-based add-on configuration

### Day 3: Remaining Steps
- [ ] Create Step 3: Upsells
- [ ] Create Step 4: Pricing & Availability
- [ ] Create Step 5: Review with POS preview
- [ ] Create POSModifierPreview widget

### Day 4: Integration
- [ ] Create main wizard screen
- [ ] Create WizardStepper widget
- [ ] Create SummarySidebar widget
- [ ] Wire up navigation
- [ ] Implement unsaved changes handling

### Day 5: Polish & Testing
- [ ] Add all validation rules
- [ ] Test all user flows
- [ ] Fix any UI/UX issues
- [ ] Add loading states
- [ ] Add error handling
- [ ] Code review and cleanup

---

## 🚀 Quick Start Commands

Once implemented, use:

```bash
# Run the app
flutter run -d chrome

# Navigate to menu editor
# Click "Add New Item"
# The wizard opens

# Test flow:
# 1. Enter item details
# 2. Add sizes and configure add-ons
# 3. Select upsells
# 4. Set availability
# 5. Review in POS preview
# 6. Save
```

---

## 📞 Support

For questions during implementation:
1. Refer to React implementation in `/Users/james2/Documents/OZPOSTSX/Ozpos-APP/components/AddEditItemScreen.tsx`
2. Check screenshots for visual reference
3. Review this document for architecture guidance

---

**Last Updated**: January 10, 2025
**Status**: ✅ Entities created, ready for implementation
**Next Step**: Create mock data and BLoC foundation
