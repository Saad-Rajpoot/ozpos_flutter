# Menu Item Wizard - Critical Fixes Needed

## Issues Identified

### 1. Step 2: Common Sizes Addition ❌
**Problem**: Dialog selects sizes but doesn't actually add them with proper names
**Fix**: Modify `AddSize` event to accept optional size name parameter
**Files**: 
- `menu_edit_event.dart` - Update AddSize event
- `menu_edit_bloc.dart` - Handle size name in AddSize
- `step2_sizes_addons.dart` - Pass size names when adding

### 2. Copy Dine-In Prices ✅
**Status**: Already implemented in `_copyPricesAcrossChannels` (line 315-340)
**Note**: Should work once sizes are properly added

### 3. Category Names Display ❌
**Problem**: Shows "cat-1" instead of "Pizza" 
**Fix**: Add category name mapping in Step 1
**Files**:
- `step1_item_details.dart` - Map category IDs to names in dropdown

### 4. Edit Mode - Auto-load Data ❌
**Problem**: When editing existing item, fields are empty
**Fix**: Initialize wizard with existing item data
**Files**:
- `menu_item_wizard_screen.dart` - Pass existing item to InitializeMenuEdit
- `menu_edit_bloc.dart` - Load existing item data into state

### 5. Comprehensive Addon Management System ❌
**Problem**: No reusable addon system
**Solution**: Need entirely new addon architecture
**Components Needed**:
- Addon Category entity (Cheese, Sauces, Crust)
- Addon Item entity (Mozzarella, Cheddar, etc.)
- Addon Rules (required, min/max selection, pricing)
- Addon BLoC for management
- Addon selection UI in Step 2
**Estimated Time**: 4-6 hours of development

### 6. Addon Rules System ❌
**Requirements**:
- Optional vs Required
- Min/Max selections (e.g., "Select 1", "Select up to 3")
- Individual pricing per addon
- Item-specific pricing overrides
**Part of**: Addon Management System (#5)

### 7. Real Menu Items in Upsells ❌
**Problem**: Shows placeholder "Menu Item 1, 2, 3"
**Fix**: Fetch actual menu items from MenuBloc
**Files**:
- `step3_upsells.dart` - Replace mock data with MenuBloc items

### 8. Base Price Handling ❌
**Problem**: Can't edit base price, size pricing doesn't override base
**Fix**: 
- Add base price field in Step 1
- Logic: If sizes exist, use size pricing; else use base price
**Files**:
- `step1_item_details.dart` - Add base price field
- `menu_item_edit_entity.dart` - Ensure basePrice is editable

### 9. Menu Modifier Preview in Step 5 ❌
**Problem**: Can't preview how item will look in configurator
**Solution**: Embed ItemConfiguratorDialog as preview in Step 5
**Files**:
- `step5_review.dart` - Add preview section
- May need to extract configurator as reusable widget

## Recommended Fix Order

### Phase 1: Quick Wins (30-60 min)
1. Fix category names display (Step 1)
2. Fix common sizes addition (Step 2)  
3. Replace placeholder upsells with real items (Step 3)

### Phase 2: Core Functionality (1-2 hours)
4. Fix base price editing (Step 1)
5. Implement edit mode - auto-load existing data
6. Add modifier preview (Step 5)

### Phase 3: Advanced Features (4-6 hours)
7. Build comprehensive Addon Management System
8. Implement addon rules and constraints

## Immediate Actions

Given time constraints, I recommend focusing on **Phase 1** fixes which will make the wizard functional for basic use cases. Phase 2 and 3 can be implemented iteratively.

Would you like me to:
A) Implement all Phase 1 fixes now (~1 hour)
B) Focus on specific high-priority items
C) Create a minimal working version first, then iterate
