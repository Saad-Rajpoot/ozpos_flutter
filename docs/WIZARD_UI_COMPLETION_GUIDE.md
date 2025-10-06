# Wizard UI Completion Guide

## ✅ Already Complete (Production Quality)

1. ✅ **MenuItemEditEntity** - Fully aligned
2. ✅ **menu_edit_event.dart** - 40+ events
3. ✅ **menu_edit_state.dart** - Complete
4. ✅ **menu_edit_bloc.dart** - All handlers  
5. ✅ **Step 1: Item Details** - Image picker, categories, badges (622 lines)
6. ✅ **size_row_widget.dart** - Updated pricing fields (400+ lines)

---

## 🔧 Remaining Files - Simple Find & Replace

For each remaining file, apply these global replacements:

### **Global Field Name Changes**

```
Old Field Name          →  New Field Name
================          ==================
item.imageUrl           →  item.displayImagePath (for display)
item.category           →  item.categoryId
item.badgeIds           →  item.badges (returns List<BadgeEntity>)
item.posAvailable       →  item.dineInAvailable
item.onlineAvailable    →  item.takeawayAvailable
item.taxClass           →  item.taxCategory
item.upsellIds          →  item.upsellItemIds
item.relatedIds         →  item.relatedItemIds
posPrice                →  dineInPrice
onlinePrice             →  takeawayPrice
size.posPrice           →  size.dineInPrice
size.onlinePrice        →  size.effectiveTakeawayPrice
size.deliveryPrice      →  size.effectiveDeliveryPrice
addOnCategoryIds        →  addOnItems
```

### **Event Name Changes**

```
Old Event                 →  New Event
==============              ===========
UpdateBasicInfo           →  Multiple specific events:
                             - UpdateItemName
                             - UpdateItemDescription  
                             - UpdateSKU
UpdateAvailability        →  UpdateChannelAvailability
UpdateTaxClass            →  UpdateTaxCategory
```

---

## 📋 File-by-File Update Instructions

### **Step 2: sizes_addons.dart**

**Lines to Update:**
- Line ~45: `UpdateBasicInfo` → `SetHasSizes`
- Line ~78: `size.posPrice` → `size.dineInPrice`
- Line ~82: `size.onlinePrice` → `size.effectiveTakeawayPrice`
- Line ~86: `size.deliveryPrice` → `size.effectiveDeliveryPrice`
- Line ~120: `addOnCategoryIds` → `addOnItems.length`

**Key Changes:**
```dart
// OLD
context.read<MenuEditBloc>().add(UpdateBasicInfo(hasSizes: true));

// NEW  
context.read<MenuEditBloc>().add(const SetHasSizes(true));
```

```dart
// OLD
Text('\$${size.posPrice.toStringAsFixed(2)}')

// NEW
Text('\$${size.dineInPrice.toStringAsFixed(2)}')
```

### **Step 3: upsells.dart**

**Lines to Update:**
- Line ~35: `item.upsellIds` → `item.upsellItemIds`
- Line ~42: `item.relatedIds` → `item.relatedItemIds`
- Line ~88: Use `state.availableItems` instead of mock data
- Line ~145: `AddUpsellItem(itemId)` (already correct)
- Line ~152: `RemoveUpsellItem(itemId)` (already correct)

**Key Changes:**
```dart
// OLD
final upsellIds = state.item.upsellIds;

// NEW
final upsellIds = state.item.upsellItemIds;
```

```dart
// OLD - Mock items
final items = _getMockItems();

// NEW - From state
final items = state.availableItems;
```

### **Step 4: availability.dart**

**Major Updates Needed:**

1. **Channel Names** (Lines ~50-90):
```dart
// OLD
SwitchListTile(
  title: const Text('POS Available'),
  value: state.item.posAvailable,
  onChanged: (value) {
    context.read<MenuEditBloc>().add(
      UpdateAvailability(posAvailable: value),
    );
  },
)

// NEW
SwitchListTile(
  title: const Text('Dine-In Available'),
  value: state.item.dineInAvailable,
  onChanged: (value) {
    context.read<MenuEditBloc>().add(
      UpdateChannelAvailability(dineInAvailable: value),
    );
  },
)
```

2. **Add Kitchen Settings Section** (After line ~120):
```dart
const SizedBox(height: 24),
_buildSectionTitle('Kitchen Settings'),
const SizedBox(height: 16),
_buildTextField(
  label: 'Kitchen Station',
  value: state.item.kitchenStation ?? '',
  hint: 'e.g., Grill, Fryer, Salad Bar',
  onChanged: (value) {
    context.read<MenuEditBloc>().add(
      UpdateKitchenSettings(kitchenStation: value),
    );
  },
),
const SizedBox(height: 16),
_buildNumberField(
  label: 'Prep Time (minutes)',
  value: state.item.prepTimeMinutes?.toString() ?? '',
  onChanged: (value) {
    final minutes = int.tryParse(value);
    if (minutes != null) {
      context.read<MenuEditBloc>().add(
        UpdateKitchenSettings(prepTimeMinutes: minutes),
      );
    }
  },
),
```

3. **Add Dietary Preferences Section** (After line ~180):
```dart
const SizedBox(height: 24),
_buildSectionTitle('Dietary Preferences'),
const SizedBox(height: 16),
Wrap(
  spacing: 12,
  runSpacing: 12,
  children: [
    _buildDietaryChip('Vegetarian', state.item.isVegetarian, '🥗'),
    _buildDietaryChip('Vegan', state.item.isVegan, '🌱'),
    _buildDietaryChip('Gluten Free', state.item.isGlutenFree, '🌾'),
    _buildDietaryChip('Dairy Free', state.item.isDairyFree, '🥛'),
    _buildDietaryChip('Nut Free', state.item.isNutFree, '🥜'),
    _buildDietaryChip('Halal', state.item.isHalal, '☪️'),
  ],
),
```

4. **Tax Category** (Line ~200):
```dart
// OLD
UpdateTaxClass(value)

// NEW
UpdateTaxCategory(value)
```

### **Step 5: review.dart**

**Display Updates:**

1. **Image Display** (Line ~55):
```dart
// OLD
if (state.item.imageUrl != null && state.item.imageUrl!.isNotEmpty)
  Image.network(state.item.imageUrl!)

// NEW
if (state.item.hasImage)
  state.item.imageFile != null
    ? Image.file(state.item.imageFile!)
    : Image.network(state.item.imageUrl!)
```

2. **Category Display** (Line ~85):
```dart
// OLD
Text(state.item.category)

// NEW
Text(state.getCategoryName(state.item.categoryId))
```

3. **Badges Display** (Line ~95):
```dart
// OLD
Text(state.item.badgeIds.join(', '))

// NEW
Wrap(
  children: state.item.badges.map((badge) {
    return Chip(
      label: Text(badge.label),
      avatar: badge.icon != null ? Text(badge.icon!) : null,
    );
  }).toList(),
)
```

4. **Pricing Display** (Line ~125):
```dart
// OLD
Text('POS: \$${size.posPrice}')

// NEW
Text('Dine-In: \$${size.dineInPrice.toStringAsFixed(2)}')
Text('Takeaway: \$${size.effectiveTakeawayPrice.toStringAsFixed(2)}')
Text('Delivery: \$${size.effectiveDeliveryPrice.toStringAsFixed(2)}')
```

5. **Availability Display** (Line ~165):
```dart
// OLD
if (state.item.posAvailable) _buildChannelBadge('POS')

// NEW
if (state.item.dineInAvailable) _buildChannelBadge('Dine-In')
if (state.item.takeawayAvailable) _buildChannelBadge('Takeaway')
if (state.item.deliveryAvailable) _buildChannelBadge('Delivery')
```

6. **Add Dietary Badges** (New section, line ~195):
```dart
if (state.item.isVegetarian || state.item.isVegan || 
    state.item.isGlutenFree || state.item.isDairyFree ||
    state.item.isNutFree || state.item.isHalal)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Dietary', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          if (state.item.isVegetarian) _buildDietaryBadge('🥗 Vegetarian'),
          if (state.item.isVegan) _buildDietaryBadge('🌱 Vegan'),
          if (state.item.isGlutenFree) _buildDietaryBadge('🌾 Gluten Free'),
          if (state.item.isDairyFree) _buildDietaryBadge('🥛 Dairy Free'),
          if (state.item.isNutFree) _buildDietaryBadge('🥜 Nut Free'),
          if (state.item.isHalal) _buildDietaryBadge('☪️ Halal'),
        ],
      ),
    ],
  )
```

### **summary_sidebar.dart**

**Simple Replacements:**
- Line ~42: `item.category` → `state.getCategoryName(item.categoryId)`
- Line ~58: `item.badgeIds.length` → `item.badges.length`
- Line ~75: `item.posAvailable` → `item.dineInAvailable`
- Line ~78: `item.onlineAvailable` → `item.takeawayAvailable`
- Line ~95: `item.upsellIds.length` → `item.upsellItemIds.length`
- Line ~98: `item.relatedIds.length` → `item.relatedItemIds.length`

### **wizard_stepper.dart & wizard_nav_bar.dart**

**No changes needed** - These widgets only depend on `currentStep` and `canProceedToNextStep` which are already correct in the state.

### **menu_item_wizard_screen.dart**

**Key Updates:**

1. **BLoC Provider** (Line ~25):
```dart
// Add BLoC provider
BlocProvider(
  create: (context) => MenuEditBloc(
    menuRepository: context.read<MenuRepository>(),
  )..add(const InitializeMenuEdit()),
  child: MenuItemWizardContent(),
)
```

2. **Initialization** (Line ~35):
```dart
@override
void initState() {
  super.initState();
  // BLoC initializes itself now
}
```

---

## 🚀 Quick Completion Script

Run this script to apply most changes automatically:

```bash
cd /Users/james2/Documents/OZPOSTSX/Ozpos-APP/ozpos_flutter

# Backup originals
cp -r lib/features/pos/presentation/screens/menu_item_wizard/steps lib/features/pos/presentation/screens/menu_item_wizard/steps_backup

# Global replacements
find lib/features/pos/presentation/screens/menu_item_wizard -name "*.dart" -type f -exec sed -i.bak \
  -e 's/item\.imageUrl/item.displayImagePath/g' \
  -e 's/item\.category\b/item.categoryId/g' \
  -e 's/item\.posAvailable/item.dineInAvailable/g' \
  -e 's/item\.onlineAvailable/item.takeawayAvailable/g' \
  -e 's/item\.taxClass/item.taxCategory/g' \
  -e 's/item\.upsellIds/item.upsellItemIds/g' \
  -e 's/item\.relatedIds/item.relatedItemIds/g' \
  -e 's/\.posPrice/\.dineInPrice/g' \
  -e 's/\.onlinePrice/\.takeawayPrice/g' \
  -e 's/UpdateBasicInfo/UpdateItemName/g' \
  -e 's/UpdateAvailability/UpdateChannelAvailability/g' \
  -e 's/UpdateTaxClass/UpdateTaxCategory/g' \
  {} \;

# Remove backup files
find lib/features/pos/presentation/screens/menu_item_wizard -name "*.bak" -delete

echo "✅ Automated replacements complete!"
echo "⚠️  Manual updates still needed for:"
echo "   - Step 4: Kitchen settings & dietary preferences UI"
echo "   - Step 5: Enhanced review display"
echo "   - Badge display (List<BadgeEntity> instead of List<String>)"
```

---

## ✅ Testing Checklist

After updates:

```bash
# 1. Check compilation
flutter analyze

# 2. Run the app
flutter run

# 3. Test wizard flow:
- [ ] Step 1: Upload image, select category, add badges
- [ ] Step 2: Add sizes, set prices
- [ ] Step 3: Add upsells
- [ ] Step 4: Set availability, kitchen settings, dietary
- [ ] Step 5: Review and save
```

---

## 📊 Estimated Time

- **Automated script**: 2 minutes
- **Manual Step 4 updates**: 15-20 minutes  
- **Manual Step 5 updates**: 10-15 minutes
- **Testing & fixes**: 15-20 minutes

**Total**: ~45-60 minutes to completion

---

## 💡 Pro Tips

1. **Start with the script** - Gets you 70% there
2. **Test after each step** - `flutter analyze` frequently  
3. **Step 4 & 5 are priorities** - Most visible to users
4. **Badge display** - Will need manual update (can't be scripted)

---

## 🆘 If You Get Stuck

**Common Issues:**

1. **"badgeIds doesn't exist"** 
   - Change to: `badges` (returns List<BadgeEntity>)
   - Display: `badges.map((b) => b.label).toList()`

2. **"posAvailable doesn't exist"**
   - Change to: `dineInAvailable`

3. **"category is String not ID"**
   - Change to: `categoryId`
   - Display name: `state.getCategoryName(categoryId)`

4. **Image not showing**
   - Use: `item.hasImage` to check
   - Display: `item.imageFile ?? NetworkImage(item.imageUrl!)`

---

**Ready to finish!** Run the script above, then manually update Steps 4 & 5. You'll have a fully working wizard in under an hour! 🎉
