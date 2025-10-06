# Checkout Screen Refactor - Implementation Plan

## 🎯 Objective
Refactor the checkout UI to match the compact, production-ready React prototype with:
- Always-visible order items (no empty cart issue)
- Fixed three-column layout with proper widths
- Compact spacing (no unnecessary scrolling)
- Responsive behavior (<900dp drawer, ≥900dp inline)

## 📐 Layout Specification

### Three-Column Structure (Row)
```
┌─────────────────────────────────────────────────────────────┐
│ [Left: 320-360dp]  [Middle: Flexible]  [Right: 320dp]       │
│                                                               │
│ Order Items        Payment Keypad      Payment Options       │
│ ┌──────────┐      ┌──────────────┐    ┌──────────────┐     │
│ │ • Item 1 │      │ Quick Amounts│    │ Single|Split │     │
│ │ • Item 2 │      │ ┌──┬──┬──┐  │    │ ┌──┬──┬──┐  │     │
│ │ • Item 3 │      │ │7 │8 │9 │  │    │ │$│Card│💳│  │     │
│ │          │      │ ├──┼──┼──┤  │    │ └──┴──┴──┘  │     │
│ │ (scroll) │      │ │4 │5 │6 │  │    │              │     │
│ │          │      │ ├──┼──┼──┤  │    │ Amount       │     │
│ │          │      │ │1 │2 │3 │  │    │ Received     │     │
│ ├──────────┤      │ ├──┼──┼──┤  │    │              │     │
│ │ Summary  │      │ │.│0 │⌫ │  │    │ ▼ Tip        │     │
│ │ (sticky) │      │ └──┴──┴──┘  │    │ ▼ Discount   │     │
│ └──────────┘      │              │    │              │     │
│                    │ Totals Card  │    │ [PAY $XX.XX] │     │
│                    └──────────────┘    │ [Pay Later]  │     │
│                                        └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### Breakpoint Behavior
- **< 900dp (compact)**: Order items in drawer, cart icon with badge
- **901-1279dp (medium)**: Left column 320dp fixed
- **≥ 1280dp (large)**: Left column 360dp fixed

### At 1366x768 (target resolution):
- Left: 360dp
- Middle: ~520dp (flexible)
- Right: 320dp
- Gaps: 2x 12dp = 24dp
- Page margins: 2x 16dp = 32dp
- **Total: 360 + 520 + 320 + 24 + 32 = 1256dp** ✅ No scroll!

## 🎨 Compact Design Rules

### Spacing Token Usage
```dart
pageHorizontal: 16dp
cardPadding: 12dp
cardInnerPadding: 8dp
gap: 8dp (compact), 12dp (medium+)
```

### Component Heights
```dart
tabs: 48dp
methodTiles: 76dp
quickAmount: 38dp
input: 56dp
keySize: 64dp
```

### Typography
```dart
title: 16sp
label: 13sp
value: 18-20sp
body: 14sp
small: 12sp
```

## 🔧 File Structure

```
lib/features/pos/presentation/screens/checkout/
├── checkout_tokens.dart              ✅ [DONE]
├── checkout_screen_v2.dart            [NEW - Main screen]
├── widgets/
│   ├── order_items_panel.dart         [NEW - Left column]
│   ├── payment_keypad_panel.dart      [NEW - Middle column]
│   ├── payment_options_panel.dart     [NEW - Right column]
│   ├── compact_order_line.dart        [NEW - 2-row item]
│   ├── compact_summary_card.dart      [NEW - Sticky totals]
│   ├── compact_keypad.dart            [NEW - 64dp grid]
│   ├── collapsible_section.dart       [NEW - Tip/Discount]
│   └── payment_method_grid.dart       [NEW - 2-row tiles]
```

## 📝 Implementation Steps

### Step 1: Order Items Panel (Left Column) ✅
**File**: `order_items_panel.dart`

**Features**:
- Read from shared CartBloc (not new instance)
- Scrollable ListView.builder for items
- Sticky summary card at bottom using Stack/Positioned
- Compact 2-row line item:
  - Row 1: Title (ellipsis) + qty ×n + lineTotal (right)
  - Row 2: Modifier chips (horizontal scroll if needed)
- Empty state placeholder when truly empty

**Key Code**:
```dart
Column(
  children: [
    Expanded(
      // Scrollable items list
      child: ListView.builder(...),
    ),
    // Sticky summary (non-scrolling)
    CompactSummaryCard(state: checkoutState),
  ],
)
```

### Step 2: Payment Keypad Panel (Middle Column) ✅
**File**: `payment_keypad_panel.dart`

**Features**:
- Quick amounts row (single line, 38dp height)
- Fixed-height keypad grid (4 rows × 64dp = 256dp + gaps)
- Keys sized to fit: min(64dp, (availableWidth - gaps) / 3)
- Totals card directly beneath (non-scrolling)
- NO outer scroll view

**Key Code**:
```dart
Column(
  children: [
    // Quick amounts (fixed height)
    QuickAmountsRow(),
    SizedBox(height: 12),
    
    // Keypad (fixed height, 256 + gaps)
    CompactKeypad(
      keySize: 64,
      onKeyPress: (key) => ...,
    ),
    SizedBox(height: 12),
    
    // Totals (fixed height)
    CompactTotalsCard(state: state),
  ],
)
```

### Step 3: Payment Options Panel (Right Column) ✅
**File**: `payment_options_panel.dart`

**Features**:
- Single/Split tabs (48dp) at top
- Payment method grid (2 rows × 3 cols, 76dp tiles)
- Amount Received input (56dp, Cash only)
- Collapsible Tip section (collapsed by default)
- Collapsible Discount section (collapsed by default)
- Sticky actions at bottom (PAY + Pay Later)

**Key Code**:
```dart
Column(
  children: [
    // Tabs (fixed)
    TabRow(),
    
    // Method grid (fixed)
    PaymentMethodGrid(),
    
    // Scrollable middle section
    Expanded(
      child: SingleChildScrollView(
        child: Column([
          if (isCash) AmountReceivedInput(),
          CollapsibleTipSection(),
          CollapsibleDiscountSection(),
        ]),
      ),
    ),
    
    // Actions (sticky, fixed)
    ActionButtons(),
  ],
)
```

### Step 4: Main Checkout Screen V2 ✅
**File**: `checkout_screen_v2.dart`

**Features**:
- Text scale clamp (1.0 - 1.1)
- Read CartBloc from parent context
- Three-column Row layout (NO outer scroll)
- Responsive drawer for <900dp
- App bar with cart badge for compact mode

**Key Code**:
```dart
Widget build(BuildContext context) {
  final scaler = MediaQuery.textScalerOf(context).clamp(
    minScaleFactor: 1.0,
    maxScaleFactor: 1.1,
  );
  
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: scaler),
    child: Scaffold(
      backgroundColor: CheckoutTokens.background,
      appBar: isCompact ? _buildCompactAppBar() : null,
      endDrawer: isCompact ? _buildOrderDrawer() : null,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Row( // NO SingleChildScrollView wrapper!
          children: [
            if (!isCompact) OrderItemsPanel(width: leftWidth),
            if (!isCompact) SizedBox(width: gap),
            
            Expanded(child: PaymentKeypadPanel()),
            SizedBox(width: gap),
            
            SizedBox(
              width: CheckoutTokens.rightWidth,
              child: PaymentOptionsPanel(),
            ),
          ],
        ),
      ),
    ),
  );
}
```

## ✅ Acceptance Criteria

- [ ] At 1366×768: All three columns visible, no page scroll
- [ ] Order items always show (reads from shared CartBloc)
- [ ] Items list scrolls independently (only that section)
- [ ] Keypad fits without scroll (fixed 256dp + gaps height)
- [ ] Actions sticky at bottom of right column
- [ ] <900dp: Drawer with badge count
- [ ] ≥900dp: Inline left panel
- [ ] Text scale clamped to 1.0-1.1
- [ ] PAY button shows correct amount
- [ ] Change due shown for Cash
- [ ] Tip/Discount collapsed by default
- [ ] No overflow or clipped text at 1.1 scale

## 🚀 Next Steps

1. Implement `order_items_panel.dart` with compact 2-row items
2. Implement `payment_keypad_panel.dart` with fixed grid
3. Implement `payment_options_panel.dart` with collapsible sections
4. Create `checkout_screen_v2.dart` with proper layout
5. Update router to use new screen
6. Test at multiple screen sizes
7. Verify no scrolling at 1366×768

---

**Status**: Ready to implement
**Est. Time**: 2-3 hours for full implementation
**Priority**: HIGH - Fixes major UX issues with empty cart and scrolling
