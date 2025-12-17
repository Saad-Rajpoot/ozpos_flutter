# Checkout Screen Implementation Plan

## Overview
Pixel-perfect Flutter implementation of the checkout screen matching the React prototype at `/Users/james2/Documents/OZPOSTSX/Ozpos-APP/components/UnifiedCheckoutScreen.tsx`.

---

## File Structure

```
lib/
├── features/pos/
│   ├── domain/entities/
│   │   ├── payment_method.dart          # Enum: Cash, Card, Wallet, Gift, BNPL, Split
│   │   ├── tender_entity.dart           # Split payment tender model
│   │   └── checkout_state_entity.dart   # Complete checkout state
│   │
│   ├── presentation/
│   │   ├── bloc/
│   │   │   ├── checkout_bloc.dart       # Main checkout BLoC (400+ lines)
│   │   │   ├── checkout_event.dart      # All checkout events
│   │   │   └── checkout_state.dart      # Checkout states
│   │   │
│   │   └── screens/
│   │       └── checkout_screen_new.dart # Main checkout screen (800+ lines)
│   │
│   └── presentation/widgets/checkout/
│       ├── payment_method_selector.dart # Cash/Card/Wallet/Gift/BNPL/Split pills
│       ├── amount_received_card.dart    # Cash received display
│       ├── tip_selector.dart            # 5%/10%/15%/Custom chips
│       ├── loyalty_card.dart            # Points redemption card
│       ├── voucher_input.dart           # Voucher code input + presets
│       ├── keypad_widget.dart           # Number pad + quick amounts
│       ├── totals_card.dart             # Subtotal/Tax/Total display
│       ├── order_items_panel.dart       # Right panel with items
│       └── split_payment_panel.dart     # Split payment UI
```

---

## Domain Entities

### 1. Payment Method Enum
```dart
enum PaymentMethod {
  cash,
  card,
  wallet,
  gift,
  bnpl,
  split;
  
  IconData get icon {
    switch (this) {
      case PaymentMethod.cash: return Icons.payments;
      case PaymentMethod.card: return Icons.credit_card;
      case PaymentMethod.wallet: return Icons.account_balance_wallet;
      case PaymentMethod.gift: return Icons.card_giftcard;
      case PaymentMethod.bnpl: return Icons.schedule;
      case PaymentMethod.split: return Icons.call_split;
    }
  }
  
  String get label {
    switch (this) {
      case PaymentMethod.cash: return 'Cash';
      case PaymentMethod.card: return 'Card';
      case PaymentMethod.wallet: return 'Wallet';
      case PaymentMethod.gift: return 'Gift';
      case PaymentMethod.bnpl: return 'BNPL';
      case PaymentMethod.split: return 'Split';
    }
  }
}
```

### 2. Tender Entity (for split payments)
```dart
class TenderEntity {
  final String id;
  final PaymentMethod method;
  final double amount;
  final TenderStatus status;
  final String? authorizationId;
  
  const TenderEntity({
    required this.id,
    required this.method,
    required this.amount,
    required this.status,
    this.authorizationId,
  });
}

enum TenderStatus {
  pending,
  authorized,
  captured,
  failed,
  voided
}
```

---

## CheckoutBloc Logic

### State Properties
```dart
class CheckoutLoaded extends CheckoutState {
  // Mode
  final bool isSplitMode;
  
  // Payment
  final PaymentMethod selectedMethod;
  final String cashReceived;  // String for keypad entry
  
  // Tips
  final int tipPercent;  // 0, 5, 10, 15
  final String customTipAmount;
  
  // Discounts
  final int discountPercent;  // 0, 5, 10, 15
  final List<VoucherEntity> appliedVouchers;
  final double loyaltyRedemption;
  
  // Split
  final List<TenderEntity> tenders;
  
  // Cart
  final List<CartLineItem> items;
  
  // Calculated (derived)
  double get subtotal;
  double get tipAmount;
  double get discountAmount;
  double get totalBeforeTax;
  double get tax;
  double get grandTotal;
  double get cashChange;
  double get splitRemaining;
}
```

### Calculation Methods (matching React)
```dart
// From React line 72-78:
double calculateSubtotal(List<CartLineItem> items) {
  return items.fold(0.0, (sum, item) => sum + item.lineTotal);
}

double calculateTipAmount(double subtotal, int tipPercent, String customTip) {
  if (tipPercent > 0) {
    return (subtotal * tipPercent) / 100;
  }
  return double.tryParse(customTip) ?? 0.0;
}

double calculateTax(double totalBeforeTax) {
  return totalBeforeTax * 0.10;  // 10% tax
}

double calculateGrandTotal({
  required double subtotal,
  required double tipAmount,
  required double discountAmount,
  required double voucherTotal,
  required double loyaltyRedemption,
}) {
  final totalBeforeTax = subtotal + tipAmount - discountAmount - voucherTotal - loyaltyRedemption;
  final tax = totalBeforeTax * 0.10;
  return max(0.0, totalBeforeTax + tax);
}

double calculateCashChange(String cashReceived, double grandTotal) {
  final received = double.tryParse(cashReceived) ?? 0.0;
  return max(0.0, received - grandTotal);
}
```

### Events
- `InitializeCheckout(List<CartLineItem> items)`
- `SelectPaymentMethod(PaymentMethod method)`
- `KeypadPress(String key)` // '0'-'9', '00', '⌫'
- `QuickAmount(int amount)` // 5, 10, 20, 50, 100
- `SelectTipPercent(int percent)` // 0, 5, 10, 15
- `SetCustomTip(String amount)`
- `ApplyVoucher(String code)`
- `RemoveVoucher(String id)`
- `SetDiscountPercent(int percent)`
- `RedeemLoyaltyPoints(double amount)`
- `UndoLoyaltyRedemption()`
- `ToggleSplitMode()`
- `AddTender(PaymentMethod method, double amount)`
- `RemoveTender(String id)`
- `ProcessPayment()`
- `PayLater()`

---

## UI Layout (from screenshot)

### Three-Column Responsive Layout

```dart
@override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Breakpoints
      final isCompact = constraints.maxWidth <= 900;
      final isMedium = constraints.maxWidth > 900 && constraints.maxWidth <= 1279;
      final isLarge = constraints.maxWidth >= 1280;
      
      if (isCompact) {
        return _buildCompactLayout();  // Stack: Left + Middle, Order drawer
      } else if (isMedium) {
        return _buildMediumLayout();   // Three columns
      } else {
        return _buildLargeLayout();    // Three columns, max 1440dp
      }
    },
  );
}
```

### Left Panel (360px width on desktop)
```dart
Widget _buildLeftPanel() {
  return Container(
    width: 360,
    padding: EdgeInsets.all(16),
    child: SingleChildScrollView(
      child: Column(
        children: [
          // Header: Back + Title + Item count
          _HeaderRow(),
          SizedBox(height: 16),
          
          // Payment mode toggle
          _PaymentModeToggle(), // Single | Split
          SizedBox(height: 16),
          
          // Payment method selector
          PaymentMethodSelector(),
          SizedBox(height: 16),
          
          // Amount received (Cash only)
          if (state.selectedMethod == PaymentMethod.cash)
            AmountReceivedCard(),
          SizedBox(height: 16),
          
          // Tip selector
          TipSelector(),
          SizedBox(height: 16),
          
          // Loyalty card
          LoyaltyCard(),
          SizedBox(height: 16),
          
          // Voucher input
          VoucherInput(),
        ],
      ),
    ),
  );
}
```

### Middle Panel (440px width on desktop)
```dart
Widget _buildMiddlePanel() {
  return Container(
    width: 440,
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        // Quick amounts
        _QuickAmountsRow(), // $5, $10, $20, $50, $100
        SizedBox(height: 16),
        
        // Keypad
        Expanded(
          child: KeypadWidget(),
        ),
        SizedBox(height: 16),
        
        // Totals card
        TotalsCard(),
        SizedBox(height: 16),
        
        // Primary CTA: PAY $XX.XX (green)
        _PayButton(),
        SizedBox(height: 8),
        
        // Secondary: Pay Later (outline)
        _PayLaterButton(),
      ],
    ),
  );
}
```

### Right Panel (360px width on desktop)
```dart
Widget _buildRightPanel() {
  return Container(
    width: 360,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(left: BorderSide(color: Colors.grey.shade200)),
    ),
    child: Column(
      children: [
        // Header: ORDER ITEMS
        _buildHeader(),
        Divider(),
        
        // Items list
        Expanded(
          child: OrderItemsPanel(),
        ),
      ],
    ),
  );
}
```

---

## Component Specs (from screenshot)

### Payment Method Selector
```dart
// 6 pills in grid: 3x2 or 6x1 depending on width
// Each pill: 80-100px wide, 56px height
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: isSelected ? Color(0xFF3B82F6) : Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: isSelected ? Color(0xFF3B82F6) : Color(0xFFE5E7EB),
      width: isSelected ? 2 : 1,
    ),
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(method.icon, size: 20, color: isSelected ? Colors.white : Colors.grey.shade700),
      SizedBox(height: 4),
      Text(
        method.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.grey.shade700,
        ),
      ),
    ],
  ),
)
```

### Amount Received Card
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey.shade200),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'AMOUNT RECEIVED',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
      SizedBox(height: 12),
      Text(
        '\$${state.cashReceived.isEmpty ? "0.00" : state.cashReceived}',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
      ),
    ],
  ),
)
```

### Tip Selector
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('TIP (OPTIONAL)', style: labelStyle),
    SizedBox(height: 8),
    Row(
      children: [
        _TipChip(percent: 5),
        _TipChip(percent: 10),
        _TipChip(percent: 15),
        _CustomTipButton(),
      ].map((w) => Expanded(child: Padding(padding: EdgeInsets.only(right: 6), child: w))).toList(),
    ),
  ],
)

Widget _TipChip({required int percent}) {
  return GestureDetector(
    onTap: () => bloc.add(SelectTipPercent(percent)),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF3B82F6) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isSelected ? Color(0xFF3B82F6) : Colors.grey.shade300),
      ),
      child: Center(
        child: Text('$percent%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    ),
  );
}
```

### Keypad (4x3 grid)
```dart
GridView.count(
  crossAxisCount: 3,
  childAspectRatio: 1.3,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  children: [
    '1', '2', '3',
    '4', '5', '6',
    '7', '8', '9',
    '00', '0', '⌫'
  ].map((key) => _KeypadButton(key)).toList(),
)

Widget _KeypadButton(String key) {
  return Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: () => bloc.add(KeypadPress(key)),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: key == '⌫'
              ? Icon(Icons.backspace_outlined, size: 22)
              : Text(
                  key,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    ),
  );
}
```

### Totals Card
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Color(0xFFF9FAFB),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(
    children: [
      _TotalRow('Subtotal', state.subtotal),
      SizedBox(height: 8),
      _TotalRow('Tax (10%)', state.tax),
      if (state.tipAmount > 0) ...[
        SizedBox(height: 8),
        _TotalRow('Tip', state.tipAmount),
      ],
      if (state.discountAmount > 0 || state.loyaltyRedemption > 0) ...[
        SizedBox(height: 8),
        _TotalRow('Discounts', -(state.discountAmount + state.loyaltyRedemption), isNegative: true),
      ],
      Divider(height: 24),
      _TotalRow('Total', state.grandTotal, isBold: true, isTotal: true),
    ],
  ),
)

Widget _TotalRow(String label, double amount, {bool isBold = false, bool isTotal = false, bool isNegative = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: isTotal ? 18 : 14,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
          color: Color(0xFF111827),
        ),
      ),
      Text(
        '${isNegative ? "-" : ""}\$${amount.abs().toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: isTotal ? 18 : 14,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          color: isTotal ? Color(0xFF10B981) : Color(0xFF111827),
        ),
      ),
    ],
  );
}
```

### PAY Button
```dart
SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton(
    onPressed: canPay ? () => bloc.add(ProcessPayment()) : null,
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF10B981),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      disabledBackgroundColor: Colors.grey.shade300,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check, size: 20),
        SizedBox(width: 8),
        Text(
          'PAY \$${state.grandTotal.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  ),
)

// Enable logic
bool get canPay {
  if (state.selectedMethod == PaymentMethod.cash) {
    final received = double.tryParse(state.cashReceived) ?? 0.0;
    return received >= state.grandTotal;
  }
  return true; // Card/Wallet/etc always enabled
}
```

---

## Split Payment Panel

```dart
Widget _buildSplitPaymentPanel() {
  return Column(
    children: [
      // Remaining balance banner
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: state.splitRemaining > 0 ? Color(0xFFFEF3C7) : Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Remaining', style: TextStyle(fontWeight: FontWeight.w600)),
            Text('\$${state.splitRemaining.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      SizedBox(height: 16),
      
      // Split buttons
      Row(
        children: [
          _SplitButton('Split 2', () => bloc.add(SplitEvenly(2))),
          _SplitButton('Split 3', () => bloc.add(SplitEvenly(3))),
          _SplitButton('Split 4', () => bloc.add(SplitEvenly(4))),
        ],
      ),
      SizedBox(height: 16),
      
      // Tenders list
      Expanded(
        child: ListView.builder(
          itemCount: state.tenders.length,
          itemBuilder: (context, index) => _TenderCard(state.tenders[index]),
        ),
      ),
      
      // Add tender button
      TextButton.icon(
        onPressed: () => bloc.add(AddTender()),
        icon: Icon(Icons.add),
        label: Text('Add Payment'),
      ),
    ],
  );
}
```

---

## Responsive Breakpoints

```dart
extension CheckoutBreakpoints on BuildContext {
  bool get isCompactCheckout => MediaQuery.of(this).size.width <= 900;
  bool get isMediumCheckout => MediaQuery.of(this).size.width > 900 && MediaQuery.of(this).size.width <= 1279;
  bool get isLargeCheckout => MediaQuery.of(this).size.width >= 1280;
  
  double get checkoutMaxWidth => 1440;
  double get leftPanelWidth => 360;
  double get middlePanelWidth => 440;
  double get rightPanelWidth => 360;
}
```

---

## Next Steps

1. ✅ Create payment method enum
2. ✅ Create tender entity
3. ✅ Implement CheckoutBloc with all calculations
4. ✅ Build checkout screen layout
5. ✅ Build all widget components
6. ✅ Add split payment flow
7. ✅ Test all calculations
8. ✅ Validate responsive layouts

**Estimated Total Lines**: ~2,500 lines across 15 files

**Priority**: Start with CheckoutBloc and main screen, then build components incrementally.
