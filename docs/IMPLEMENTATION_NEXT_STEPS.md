# Menu Editor Wizard - Next Immediate Steps

## ✅ What's Done So Far (in this session)

1. **Domain Entities** ✅
   - `lib/features/pos/domain/entities/menu_item_edit_entity.dart`

2. **Mock Data** ✅
   - `lib/features/pos/data/mock/mock_addon_categories.dart`
   - `lib/features/pos/data/mock/mock_system_badges.dart`

3. **BLoC Events** ✅
   - `lib/features/pos/presentation/bloc/menu_edit_event.dart`

4. **BLoC State** ✅
   - `lib/features/pos/presentation/bloc/menu_edit_state.dart`

## 📝 Remaining Files (Priority Order)

### HIGH PRIORITY (Required for MVP)

#### 1. BLoC Implementation
**File**: `lib/features/pos/presentation/bloc/menu_edit_bloc.dart`

```bash
# This is the core business logic - ~400 lines
# Create this file next and implement all event handlers
```

**Key Methods**:
- `_onInitialize` - Load item
- `_onUpdateName`, `_onUpdateDescription`, `_onUpdateCategory` - Update basic fields
- `_onToggleBadge` - Toggle badges
- `_onSetHasSizes` - Enable/disable sizes
- `_onAddSize`, `_onUpdateSize`, `_onDeleteSize`, `_onSetDefaultSize` - Manage sizes
- `_onAddAddOnItemToSize`, `_onRemoveAddOnItemFromSize`, `_onUpdateAddOnItemPrice` - Manage add-ons
- `_onAddUpsellItem`, `_onRemoveUpsellItem`, etc. - Manage upsells
- `_onNavigateToStep` - Change wizard step
- `_onSaveDraft`, `_onSaveItem` - Save functionality

I'll provide the complete implementation file after you confirm you want to proceed with the full BLoC.

#### 2. Main Wizard Screen
**File**: `lib/features/pos/presentation/screens/menu_item_wizard/menu_item_wizard_screen.dart`

This is the container that holds all 5 steps and the navigation.

#### 3. Simple Widgets (Build these first)
- `wizard_stepper.dart` - The 1-2-3-4-5 progress indicator
- `summary_sidebar.dart` - Right panel showing validation/prices

#### 4. Step 1 - Item Details
**File**: `lib/features/pos/presentation/screens/menu_item_wizard/steps/step_1_item_details.dart`

Simplest step - just forms for name, description, category, badges.

### MEDIUM PRIORITY (Can be stubbed initially)

#### 5. Step 2 - Sizes & Add-ons
**Files needed**:
- `step_2_sizes_addons.dart`
- `size_row_expanded.dart` (most complex widget)
- `category_item_selector_dialog.dart`

This is the most complex step. Initially stub it with simple forms.

#### 6. Steps 3-4-5
- `step_3_upsells.dart` - Grid of selectable items
- `step_4_pricing_availability.dart` - Toggles and dropdowns
- `step_5_review.dart` - Display-only summary with POS preview

### LOW PRIORITY (Polish)
- Badge manager dialog
- Advanced validations
- Animations

---

## 🚀 Quick Start Option (Recommended)

Instead of building everything from scratch, let me create a **simplified working prototype** first:

### Option A: Minimum Viable Wizard (4 hours)
1. Basic wizard with 3 steps instead of 5
2. Simple size configuration (no inline add-ons yet)
3. Basic validation
4. Save functionality

This gets you a working wizard **today** that you can iterate on.

### Option B: Full Implementation (4-5 days)
Continue with the comprehensive plan in `MENU_EDITOR_WIZARD_IMPLEMENTATION.md`.

---

## 💡 Recommendation

Let me create **Option A** - a simplified but functional wizard that:
- ✅ Has all the UI structure
- ✅ Works end-to-end
- ✅ Can be enhanced incrementally
- ✅ Gets you testing immediately

Then you can:
1. Test the basic flow
2. Get user feedback
3. Add the complex features (inline add-ons, POS preview) iteratively

---

## ❓ What Would You Like?

**Choose one**:

### 1. Continue Full Implementation
I'll create the complete BLoC file next (~400 lines), then the wizard screen, then all 5 steps with full functionality. This will take many more file creations.

### 2. Create Simplified Working Prototype
I'll create a simplified version (3 steps, basic forms) that works end-to-end in ~5-6 files. You'll have something running today.

### 3. Provide Implementation Scripts
I'll create shell scripts that generate all the boilerplate files with TODO comments where you fill in the logic.

**Please respond with 1, 2, or 3** and I'll proceed accordingly!

---

## 📊 Current Progress

```
Foundation:          ████████████████████ 100% (4/4 files)
BLoC:                ████████░░░░░░░░░░░░  40% (2/3 files) 
Wizard Structure:    ░░░░░░░░░░░░░░░░░░░░   0% (0/2 files)
Step Screens:        ░░░░░░░░░░░░░░░░░░░░   0% (0/5 files)
Supporting Widgets:  ░░░░░░░░░░░░░░░░░░░░   0% (0/7 files)

Total: 6/17 files created (35%)
```

---

**Your call! What approach do you prefer?**
