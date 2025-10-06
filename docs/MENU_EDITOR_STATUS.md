# Menu Editor Wizard - Implementation Status

## ✅ What's Been Created

### 1. Domain Entities (Complete)
**File**: `lib/features/pos/domain/entities/menu_item_edit_entity.dart` (239 lines)

- ✅ `MenuItemEditEntity` - Main menu item with all fields
- ✅ `SizeEditEntity` - Size with per-channel pricing and add-ons
- ✅ `AddOnItemEditEntity` - Individual add-on item with price override
- ✅ `AddOnCategoryEntity` - Category of add-on options
- ✅ `AddOnOptionEntity` - Single add-on option
- ✅ `BadgeEntity` - System and custom badges
- ✅ `ValidationResult` - Validation errors and warnings

**Key Features**:
- Per-channel pricing with inheritance (takeaway/delivery can inherit from dine-in)
- Size-based add-on configuration (each size has its own add-on items with custom prices)
- Complete validation support
- Proper immutability with copyWith methods

### 2. Implementation Guide (Complete)
**File**: `MENU_EDITOR_WIZARD_IMPLEMENTATION.md` (1,025 lines)

Comprehensive implementation plan including:
- Complete file structure (17 files, ~5,250 lines total)
- Phase-by-phase implementation guide (5 days)
- Code examples for all major components
- Design specifications (colors, spacing, borders)
- Acceptance criteria
- Testing plan with example tests
- Implementation checklist

---

## 📋 Implementation Roadmap

### Phase 1: Foundation (Day 1)
- [x] Domain entities ✅
- [ ] Mock data (add-on categories, system badges)
- [ ] BLoC setup (events, state, bloc class)
- [ ] Step 1: Item Details screen

### Phase 2: Sizes & Add-ons (Day 2)
- [ ] `SizeRowExpanded` widget (expandable row with blue panel)
- [ ] `CategoryItemSelectorDialog` (select add-ons from categories)
- [ ] Step 2: Sizes & Add-ons screen
- [ ] Test inline add-on configuration

### Phase 3: Remaining Steps (Day 3)
- [ ] Step 3: Upsells & Suggestions
- [ ] Step 4: Pricing & Availability
- [ ] Step 5: Review & Save with POS preview
- [ ] `POSModifierPreview` widget

### Phase 4: Integration (Day 4)
- [ ] Main wizard screen with stepper
- [ ] `WizardStepper` widget (progress indicator)
- [ ] `SummarySidebar` widget (right panel)
- [ ] Navigation and routing
- [ ] Unsaved changes handling

### Phase 5: Polish (Day 5)
- [ ] Complete validation rules
- [ ] Test all flows
- [ ] Loading states
- [ ] Error handling
- [ ] Code review

---

## 🎯 Key Features to Implement

### 1. Size-Based Add-On Configuration
The most complex part of the system. Each size can have:
- Different add-on items
- Different prices for the same add-on
- Configuration done inline (expand row → blue panel)

**Example**:
```
Personal Size:
  - Cheddar Cheese: $1.50
  - Mozzarella: $1.50
  
Large Size:
  - Cheddar Cheese: $2.00 (price override)
  - Mozzarella: $2.00
  - Blue Cheese: $2.50 (only available on large)
```

### 2. Per-Channel Pricing with Inheritance
- Dine-in price is required
- Takeaway can inherit or have custom price
- Delivery can inherit or have custom price

**UI**: Shows "Inherit" option or price input field

### 3. Live POS Preview (Step 5)
A simulated POS modifier popup showing:
- Size selection buttons
- Add-ons grouped by category
- Price calculation
- Upsell suggestions
- Updates in real-time as you change data

### 4. Validation System
- Real-time validation as user types
- Inline error messages
- Summary in right sidebar
- Blocks navigation to Step 5 if errors exist

---

## 📁 File Organization

```
lib/features/pos/
├── domain/entities/
│   └── menu_item_edit_entity.dart ✅ DONE
│
├── data/mock/
│   ├── mock_addon_categories.dart      [TODO]
│   └── mock_system_badges.dart         [TODO]
│
├── presentation/
│   ├── bloc/
│   │   ├── menu_edit_event.dart        [TODO]
│   │   ├── menu_edit_state.dart        [TODO]
│   │   └── menu_edit_bloc.dart         [TODO]
│   │
│   └── screens/menu_item_wizard/
│       ├── menu_item_wizard_screen.dart        [TODO]
│       ├── steps/
│       │   ├── step_1_item_details.dart        [TODO]
│       │   ├── step_2_sizes_addons.dart        [TODO]
│       │   ├── step_3_upsells.dart             [TODO]
│       │   ├── step_4_pricing_availability.dart [TODO]
│       │   └── step_5_review.dart              [TODO]
│       └── widgets/
│           ├── wizard_stepper.dart             [TODO]
│           ├── summary_sidebar.dart            [TODO]
│           ├── size_row_expanded.dart          [TODO]
│           ├── category_item_selector_dialog.dart [TODO]
│           ├── badge_selector.dart             [TODO]
│           ├── badge_manager_dialog.dart       [TODO]
│           └── pos_modifier_preview.dart       [TODO]
```

---

## 🎨 Design System

### Colors (Matching React Prototype)
```dart
Primary Blue:    #2196F3
Success Green:   #10B981
Error Red:       #EF4444
Warning Orange:  #F59E0B
Purple:          #8B5CF6
Expanded Panel:  #EFF6FF (Blue-50)
Border Gray:     #E5E7EB (Gray-200)
```

### Component Specifications
- **Cards**: 16px radius, 2px gray border
- **Chips**: 20px radius (full rounded)
- **Buttons**: 12px radius
- **Step Indicator**: Circle 32px, green checkmark when complete
- **Expanded Panel**: Light blue background (#EFF6FF)
- **Spacing**: 16px between major sections, 24px padding

---

## 🔧 Technical Requirements

### BLoC Events (20+ events)
- Initialize, update fields (name, description, category)
- Toggle badges, set has sizes
- Add/update/delete sizes
- Set default size
- Add/remove add-on items per size
- Update add-on prices
- Add/remove upsells and related items
- Update availability
- Save draft, save item, duplicate

### State Management
- Current step (1-5)
- Item data (MenuItemEditEntity)
- Validation results
- Has unsaved changes flag
- Loading/saving status

### Validation Rules
- Name required
- Category required
- At least one size if hasSizes=true
- Base price > 0 if hasSizes=false
- Exactly one default size
- At least one channel available
- Valid pricing (no negative numbers)

---

## 💡 Implementation Tips

### 1. Start with Mock Data
Create comprehensive mock data first:
- 4-5 add-on categories with 5-7 items each
- 10+ system badges
- Sample menu items for upsells/related

### 2. Build Bottom-Up
- Start with small widgets (badge chip, price input)
- Build up to complex widgets (size row, category selector)
- Finally assemble into steps and main screen

### 3. Test Incrementally
- Test each widget in isolation
- Test each step before moving to next
- Test full wizard flow at the end

### 4. Use Hot Reload
- Flutter's hot reload is perfect for UI iteration
- Make changes, see results immediately
- Iterate quickly on spacing, colors, layout

---

## 📊 Estimated Effort

| Component | Lines | Time |
|-----------|-------|------|
| Mock Data | 300 | 1 hour |
| BLoC (events, state, bloc) | 650 | 3 hours |
| Step 1: Item Details | 400 | 3 hours |
| Step 2: Sizes & Add-ons | 1,100 | 8 hours |
| Step 3: Upsells | 400 | 2 hours |
| Step 4: Pricing & Availability | 350 | 2 hours |
| Step 5: Review & POS Preview | 950 | 6 hours |
| Main Wizard Screen | 600 | 4 hours |
| Supporting Widgets | 1,500 | 6 hours |
| **Total** | **5,250** | **35 hours** |

**Realistic Timeline**: 4-5 days of focused development

---

## ✅ Next Steps

### Immediate (Today)
1. Review the implementation guide thoroughly
2. Set up directory structure
3. Create mock data files
4. Start BLoC implementation

### Day 1
- Complete BLoC foundation
- Implement Step 1: Item Details
- Test basic form flow

### Days 2-3
- Implement Step 2 (most complex)
- Test size-based add-on configuration
- Implement Steps 3-4

### Days 4-5
- Implement Step 5 with POS preview
- Complete main wizard screen
- Test, polish, and fix issues

---

## 🎯 Success Criteria

The implementation is complete when:
- [ ] All 5 steps implemented and tested
- [ ] POS preview shows correctly configured items
- [ ] Size-based add-on pricing works correctly
- [ ] Validation prevents invalid states
- [ ] Unsaved changes are tracked
- [ ] Can save draft and complete item
- [ ] Matches screenshots visually
- [ ] Smooth animations and transitions
- [ ] No performance issues on target devices

---

## 📚 Resources

### Reference Implementation
- **React App**: `/Users/james2/Documents/OZPOSTSX/Ozpos-APP/components/AddEditItemScreen.tsx`
- **Size Row**: `/Users/james2/Documents/OZPOSTSX/Ozpos-APP/components/size-addon-inline/SizeRowWithAddons.tsx`
- **Category Selector**: `/Users/james2/Documents/OZPOSTSX/Ozpos-APP/components/size-addon-inline/CategoryItemSelector.tsx`

### Documentation
- **Full Guide**: `MENU_EDITOR_WIZARD_IMPLEMENTATION.md`
- **Screenshots**: Provided in original request (4 images)
- **PRD**: `prd.md` (Section on Menu Editor)

---

## 🚀 Ready to Start!

You now have:
- ✅ Complete domain entities
- ✅ Comprehensive implementation guide
- ✅ Clear roadmap and timeline
- ✅ Design specifications
- ✅ Testing strategy
- ✅ Success criteria

**Start implementing by creating the mock data files, then move on to the BLoC setup!**

---

**Status**: 🟢 Ready for Implementation
**Last Updated**: January 10, 2025
**Next Action**: Create mock data files
