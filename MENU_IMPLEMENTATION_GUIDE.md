# Menu Screen Implementation Guide - Pixel-Perfect React Replication

## Overview
This guide provides the complete implementation strategy to replicate the React prototype's Menu & Ordering experience in Flutter, maintaining pixel-perfect accuracy across all device breakpoints.

## ✅ Completed Domain Models

### Entities Created
- ✅ `ModifierOptionEntity` - Individual options with price deltas
- ✅ `ModifierGroupEntity` - Groups with min/max selection rules
- ✅ `ComboOptionEntity` - Combo upsell options
- ✅ `TableEntity` - Table management with status and floor position

## 🎯 Implementation Roadmap

### Phase 1: Extended Menu Item Entity (HIGH PRIORITY)

Create `MenuItemEntityExtended` to include:

```dart
class MenuItemEntityExtended extends MenuItemEntity {
  final List<ModifierGroupEntity> modifierGroups;
  final List<ComboOptionEntity> comboOptions;
  final List<String> recommendedAddOnIds;
  final bool hasRequiredModifiers;
  final bool isFastAdd; // Can add without opening configurator
  
  const MenuItemEntityExtended({
    // ... base props
    this.modifierGroups = const [],
    this.comboOptions = const [],
    this.recommendedAddOnIds = const [],
    this.hasRequiredModifiers = false,
  }) : isFastAdd = !hasRequiredModifiers,
       super(...);
}
```

### Phase 2: Item Configuration State

Create a BLoC to manage the configurator dialog state:

```dart
// lib/features/pos/presentation/bloc/item_config_bloc.dart

class ItemConfigBloc extends Bloc<ItemConfigEvent, ItemConfigState> {
  ItemConfigBloc() : super(ItemConfigInitial()) {
    on<InitializeItemConfig>(_onInitialize);
    on<SelectModifierOption>(_onSelectOption);
    on<SelectComboOption>(_onSelectCombo);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ResetConfiguration>(_onReset);
  }

  Future<void> _onInitialize(event, emit) async {
    // Load item, apply defaults
    // Calculate initial price
  }

  Future<void> _onSelectOption(event, emit) async {
    // Enforce max N
    // Recalculate price
    // Check required groups satisfied
  }
}

// Events
class InitializeItemConfig extends ItemConfigEvent {
  final MenuItemEntityExtended item;
}

class SelectModifierOption extends ItemConfigEvent {
  final String groupId;
  final String optionId;
  final bool selected; // true = add, false = remove
}

// State
class ItemConfigState {
  final MenuItemEntityExtended item;
  final Map<String, List<String>> selectedOptions; // groupId -> [optionIds]
  final String? selectedComboId;
  final int quantity;
  final double totalPrice;
  final bool canAddToCart; // All required groups satisfied
}
```

### Phase 3: Configurator Dialog UI

**File**: `lib/widgets/menu/item_configurator_dialog.dart`

**Structure**:
```
Dialog (max-width 520px)
├── Hero Image (200px height)
├── Title Row (name + price + Popular badge)
├── Description (2 lines, ellipsis)
├── Stepper Content (scrollable)
│   ├── Step 1: Size Selection (REQUIRED badge if needed)
│   │   ├── Radio buttons (one selection)
│   │   └── Price deltas (+$5.00 or "Free")
│   ├── Step 2: Add-ons Groups
│   │   ├── Group header with "Max N" badge
│   │   ├── Checkbox pills
│   │   └── Live count "2/2"
│   ├── Step 3: Make it a Combo (⭐ icon)
│   │   ├── Radio options
│   │   └── Price deltas
│   └── Recommended Add-ons (yellow band)
│       ├── 2 large tiles with images
│       └── Quick add buttons
└── Footer (sticky)
    ├── Quantity stepper (- 1 +)
    ├── Price breakdown (Base + Add-ons)
    ├── Reset button (text)
    └── Add $X.XX button (CTA, disabled if invalid)
```

**Key Measurements from Reference**:
- Dialog max-width: 520px
- Image height: 200px
- Section padding: 20px
- Option pill height: 44px
- Option pill radius: 8px
- Footer height: 80px
- Button height: 48px
- Gap between sections: 16px

**Exact Styles**:
```dart
// Size option (selected)
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  decoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Color(0xFF3B82F6), width: 2),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF3B82F6).withOpacity(0.1),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Row(
    children: [
      Icon(Icons.check_circle, color: Color(0xFF3B82F6)),
      SizedBox(width: 8),
      Text('Regular', style: TextStyle(fontWeight: FontWeight.w600)),
      Spacer(),
      Text('Free', style: TextStyle(color: Color(0xFF6B7280))),
    ],
  ),
)

// REQUIRED badge
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Color(0xFFFEE2E2),
    borderRadius: BorderRadius.circular(4),
  ),
  child: Text(
    'REQUIRED',
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: Color(0xFFEF4444),
      letterSpacing: 0.5,
    ),
  ),
)

// Max 2 badge
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Color(0xFFDDEAFE),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Max 2',
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Color(0xFF3B82F6),
    ),
  ),
)
```

### Phase 4: Cart Pane Component

**File**: `lib/widgets/cart/cart_pane.dart`

**Structure**:
```
Container (360px fixed width on desktop)
├── Header
│   ├── Order type segmented control (3 buttons)
│   │   ├── Dine-In (green when selected)
│   │   ├── Takeaway (orange when selected)
│   │   └── Delivery (purple when selected)
│   ├── Table selector chip (if Dine-In)
│   └── Customer search field
├── Line Items List (scrollable)
│   └── For each item:
│       ├── Icon + Name + Qty stepper
│       ├── Modifier chips (small gray pills)
│       ├── Per-item total + per-unit price
│       └── Delete icon (red)
├── Totals Section
│   ├── Subtotal row
│   ├── GST (10%) row
│   └── Total row (bold, large)
└── Actions (sticky footer)
    ├── PAY NOW button (green, primary)
    ├── SEND TO KITCHEN button (blue, secondary)
    └── Clear Cart link (red text)
```

**Exact Measurements**:
- Width: 360px (desktop), 320px (tablet-L), drawer (mobile)
- Header padding: 16px
- Line item height: ~100px
- Line item gap: 12px
- Modifier chip: 24px height, 6px radius
- Totals padding: 20px
- Button height: 48px

**Order Type Selector Style**:
```dart
Container(
  height: 48,
  decoration: BoxDecoration(
    color: Color(0xFFF3F4F6),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: orderTypes.map((type) => Expanded(
      child: _OrderTypeButton(
        label: type.name,
        icon: type.icon,
        color: type.color,
        isSelected: _selectedType == type.id,
        onTap: () => _selectType(type.id),
      ),
    )).toList(),
  ),
)
```

### Phase 5: Menu Grid with Cards

**File**: Updated `menu_screen.dart`

**Layout Specs**:
- Tablet-S (8-10"): 3-column grid, 12px gaps
- Tablet-L (iPad): 3-4 columns, 16px gaps
- Desktop: 4-5 columns, 20px gaps

**Card Specs**:
- Min width: 240px
- Aspect ratio: ~0.85 (slightly taller than wide)
- Border radius: 12px
- Shadow: elevation 2
- Padding: 12px

**Card Structure**:
```
Card
├── Image (140px height, 12px radius)
│   └── Badge overlays (Popular, price pill)
├── Content (12px padding)
│   ├── Name (16px, semi-bold, 2 lines max)
│   ├── Description (13px, gray, 2 lines max)
│   └── Price (14px, bold)
└── Actions Row
    ├── Customise button (outline, flex: 1)
    └── Add to Cart button (solid, flex: 1)
```

**Filter Chips** (category row):
```dart
Chip(
  label: Text(category.name),
  avatar: category.count != null
      ? CircleAvatar(
          child: Text('${category.count}'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        )
      : null,
  backgroundColor: isSelected ? Color(0xFFEF4444) : Colors.white,
  labelStyle: TextStyle(
    color: isSelected ? Colors.white : Color(0xFF374151),
    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
  ),
)
```

### Phase 6: Table Selection Modal

**Files**:
- `lib/widgets/table/table_selection_modal.dart`
- `lib/widgets/table/table_list_view.dart`
- `lib/widgets/table/table_floor_view.dart`

**List View Structure**:
```
Dialog
├── Header ("Select Table" + View toggle + Search)
├── Filter chips (All, Available, Occupied, Reserved)
├── Table Cards List
│   └── For each table:
│       ├── Left: Table icon + number
│       ├── Middle: Seats, Status, Server
│       └── Right: Select radio
└── Footer: Cancel / Assign Table buttons
```

**Floor View Structure**:
```
Dialog
├── Header (same as list)
├── Legend (color indicators for each status)
├── Grid (10x10) with circular table nodes
│   └── Each node shows:
│       ├── Table number (center)
│       ├── Status color (border + fill)
│       └── Tap to select (scale animation)
└── Footer (same as list)
```

**Status Colors**:
- Available: `#10B981` (green)
- Occupied: `#EF4444` (red)
- Reserved: `#3B82F6` (blue)
- Cleaning: `#F59E0B` (amber)

### Phase 7: Pricing Engine

**File**: `lib/features/pos/domain/usecases/calculate_item_price.dart`

```dart
class CalculateItemPrice {
  double call({
    required MenuItemEntityExtended item,
    required Map<String, List<String>> selectedOptions,
    String? selectedComboId,
    required int quantity,
  }) {
    double base = item.basePrice;
    
    // Add size delta (if size group exists)
    final sizeGroup = item.modifierGroups.firstWhereOrNull(
      (g) => g.name.toLowerCase().contains('size')
    );
    if (sizeGroup != null) {
      final selectedSizeId = selectedOptions[sizeGroup.id]?.first;
      if (selectedSizeId != null) {
        final option = sizeGroup.options.firstWhere((o) => o.id == selectedSizeId);
        base += option.priceDelta;
      }
    }
    
    // Add all selected add-ons
    for (var groupEntry in selectedOptions.entries) {
      if (groupEntry.key == sizeGroup?.id) continue; // Skip size
      final group = item.modifierGroups.firstWhere((g) => g.id == groupEntry.key);
      for (var optionId in groupEntry.value) {
        final option = group.options.firstWhere((o) => o.id == optionId);
        base += option.priceDelta;
      }
    }
    
    // Add combo delta
    if (selectedComboId != null) {
      final combo = item.comboOptions.firstWhere((c) => c.id == selectedComboId);
      base += combo.priceDelta;
    }
    
    return base * quantity;
  }
}
```

### Phase 8: Seed Data

**File**: `lib/core/data/seed_data.dart`

```dart
class SeedData {
  static List<MenuItemEntityExtended> getMenuItems() {
    return [
      MenuItemEntityExtended(
        id: '1',
        categoryId: 'burgers',
        name: 'Classic Burger',
        description: 'Juicy beef patty with fresh lettuce, tomato, and our signature sauce.',
        image: 'https://via.placeholder.com/300x200/F97316/FFFFFF?text=Burger',
        basePrice: 8.99,
        tags: ['Popular'],
        modifierGroups: [
          ModifierGroupEntity(
            id: 'size-1',
            name: 'Size Selection',
            isRequired: true,
            minSelection: 1,
            maxSelection: 1,
            options: [
              ModifierOptionEntity(
                id: 'size-regular',
                name: 'Regular',
                priceDelta: 0.00,
                isDefault: true,
              ),
              ModifierOptionEntity(
                id: 'size-large',
                name: 'Large',
                priceDelta: 5.00,
              ),
              ModifierOptionEntity(
                id: 'size-family',
                name: 'Family Size',
                priceDelta: 12.00,
              ),
            ],
          ),
          ModifierGroupEntity(
            id: 'sauces-1',
            name: 'Sauces',
            minSelection: 0,
            maxSelection: 2,
            options: [
              ModifierOptionEntity(id: 'sauce-ketchup', name: 'Tomato Ketchup', priceDelta: 0.00),
              ModifierOptionEntity(id: 'sauce-aioli', name: 'Garlic Aioli', priceDelta: 0.00),
              ModifierOptionEntity(id: 'sauce-bbq', name: 'BBQ Sauce', priceDelta: 1.50),
              ModifierOptionEntity(id: 'sauce-ranch', name: 'Ranch Dressing', priceDelta: 2.00),
            ],
          ),
          ModifierGroupEntity(
            id: 'cheese-1',
            name: 'Cheese Options',
            minSelection: 0,
            maxSelection: 1,
            options: [
              ModifierOptionEntity(id: 'cheese-extra', name: 'Extra Cheese', priceDelta: 3.00),
              ModifierOptionEntity(id: 'cheese-vegan', name: 'Vegan Cheese', priceDelta: 2.50),
              ModifierOptionEntity(id: 'cheese-swiss', name: 'Premium Swiss', priceDelta: 4.00),
            ],
          ),
        ],
        comboOptions: [
          ComboOptionEntity(
            id: 'combo-regular',
            name: 'Regular Combo',
            description: 'Fries + Drink',
            priceDelta: 6.50,
          ),
          ComboOptionEntity(
            id: 'combo-large',
            name: 'Large Combo',
            description: 'Large Fries + Large Drink',
            priceDelta: 8.50,
          ),
        ],
        recommendedAddOnIds: ['addon-bread', 'addon-drink'],
      ),
      // ... more items
    ];
  }
  
  static List<TableEntity> getTables() {
    return [
      TableEntity(
        id: 't1',
        number: '3',
        seats: 4,
        status: TableStatus.available,
        floorX: 2,
        floorY: 3,
      ),
      TableEntity(
        id: 't2',
        number: '3',
        seats: 4,
        status: TableStatus.occupied,
        serverName: 'Sarah',
        currentBill: 45.00,
        floorX: 5,
        floorY: 3,
      ),
      // ... more tables
    ];
  }
}
```

## 🎨 Responsive Breakpoints

```dart
// lib/utils/menu_responsive.dart

class MenuBreakpoints {
  // Tablet Small: 8-10" portrait
  static const double tabletS = 768.0;
  static const int gridColumnsTabletS = 3;
  static const double cardPaddingTabletS = 12.0;
  static const double gridGapTabletS = 12.0;
  
  // Tablet Large: 9-13" landscape
  static const double tabletL = 1024.0;
  static const int gridColumnsTabletL = 4;
  static const double cardPaddingTabletL = 16.0;
  static const double gridGapTabletL = 16.0;
  
  // Desktop: 15-20"
  static const double desktop = 1280.0;
  static const int gridColumnsDesktop = 5;
  static const double cardPaddingDesktop = 20.0;
  static const double gridGapDesktop = 20.0;
  
  // Cart pane widths
  static const double cartWidthDesktop = 360.0;
  static const double cartWidthTablet = 320.0;
}
```

## 🧪 Testing Requirements

### Golden Tests
```dart
testWidgets('Menu item card matches design', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MenuItemCard(item: mockItem),
      ),
    ),
  );
  await expectLater(
    find.byType(MenuItemCard),
    matchesGoldenFile('goldens/menu_item_card.png'),
  );
});
```

### BLoC Tests
```dart
blocTest<ItemConfigBloc, ItemConfigState>(
  'enforces max N selection',
  build: () => ItemConfigBloc(),
  act: (bloc) {
    bloc.add(InitializeItemConfig(item: itemWithMaxTwo));
    bloc.add(SelectModifierOption(groupId: 'sauces', optionId: 'opt1', selected: true));
    bloc.add(SelectModifierOption(groupId: 'sauces', optionId: 'opt2', selected: true));
    bloc.add(SelectModifierOption(groupId: 'sauces', optionId: 'opt3', selected: true)); // Should fail
  },
  expect: () => [
    // State with opt1 selected
    // State with opt1, opt2 selected
    // State unchanged (max reached)
  ],
);
```

## 📝 Implementation Priority

1. **HIGH**: Item Configurator Dialog (critical path)
2. **HIGH**: Cart Pane with line items
3. **MEDIUM**: Table Selection Modal
4. **MEDIUM**: Enhanced Menu Grid
5. **LOW**: Floor view for tables

## 🎯 Success Criteria

- [ ] Configurator matches all reference screenshots pixel-perfectly
- [ ] Required modifier validation works correctly
- [ ] Max N enforcement prevents over-selection
- [ ] Live pricing updates on every change
- [ ] Cart totals recalculate correctly
- [ ] Table selection works in both list and floor views
- [ ] All breakpoints render correctly
- [ ] No performance issues on target devices
- [ ] Golden tests pass for all key components
- [ ] BLoC unit tests cover all edge cases

---

**Next Steps**: Start with the Item Configurator Dialog as it's the most complex component. Use the exact measurements and styles provided above to ensure pixel-perfect replication.
