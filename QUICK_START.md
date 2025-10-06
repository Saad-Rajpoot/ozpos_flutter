# 🚀 Quick Start - Menu System

## Immediate Usage (3 Steps)

### 1. **Hot Reload Your App**
```bash
# Press 'r' in terminal or click hot reload button
# The new menu screen is already wired up!
```

### 2. **Navigate to Menu**
Click **"Menu"** in the sidebar, or programmatically:
```dart
Navigator.pushNamed(context, AppRouter.menu);
```

### 3. **Start Testing!**
- Browse 15 pre-loaded menu items
- Add items to cart
- Customize items with modifiers
- Try table selection
- Complete an order

---

## What You See

✅ **Menu Grid** - 15 items with images, prices, and badges  
✅ **Cart Pane** (desktop) or Cart Icon (mobile) with live counter  
✅ **Search Bar** - Filter by name or description  
✅ **Category Tabs** - Filter by category  
✅ **Responsive Design** - Works on any screen size  

---

## Testing Checklist

### ✅ Fast-Add Items (No Customization)
- Coffee ($4.50)
- Smoothie ($7.50)  
- Onion Rings ($6.50)

**Action**: Click "Add to Cart" → Item appears in cart immediately

### ✅ Customizable Items
- Classic Burger (with modifiers)
- Margherita Pizza (size + crust + toppings)
- Chicken Wings (quantity + flavor)

**Action**: Click "Customise" → Configure → Add to cart

### ✅ Cart Operations
- Change quantity with +/- buttons
- Remove items with trash icon
- Switch order type (Dine-In/Takeaway/Delivery)
- Select table (for Dine-In)
- Clear entire cart

### ✅ Responsive Test
- Resize browser window
- Watch grid columns change (2-5 columns)
- Cart pane hides below 1024px → becomes icon with badge

---

## Common Actions

### Add Item to Cart (Fast-Add)
```dart
context.read<CartBloc>().add(
  AddItemToCart(
    menuItem: item,
    quantity: 1,
    unitPrice: item.basePrice,
    selectedModifiers: {},
    modifierSummary: '',
  ),
);
```

### Open Item Configurator
```dart
ItemConfiguratorDialog.show(context, menuItem);
```

### Select Table
```dart
// Opens table selection modal
// User picks table → automatically assigned to cart
```

### Send Order to Kitchen
```dart
context.read<CartBloc>().add(ClearCart());
// In production: Send to kitchen API first
```

---

## File Locations

**Main Screen**: `lib/features/pos/presentation/screens/menu_screen_new.dart`  
**Seed Data**: `lib/core/data/seed_data.dart`  
**Cart BLoC**: `lib/features/pos/presentation/bloc/cart_bloc.dart`  
**Components**: `lib/widgets/menu/`, `lib/widgets/cart/`, `lib/widgets/table/`

---

## Need Help?

📖 **Full Documentation**: See `IMPLEMENTATION_COMPLETE.md`  
📝 **Implementation Guide**: See `MENU_IMPLEMENTATION_GUIDE.md`  
📊 **Status**: See `MENU_IMPLEMENTATION_STATUS.md`

---

## Quick Customization

### Change Colors
Edit hex values in components:
- Primary Red: `#EF4444`
- Success Green: `#10B981`
- Info Blue: `#3B82F6`

### Add Menu Item
Edit `lib/core/data/seed_data.dart`:
```dart
MenuItemEntity(
  id: 'new-item',
  name: 'New Item',
  basePrice: 10.00,
  // ... rest of properties
),
```

### Modify Grid Columns
Edit `menu_screen_new.dart` line 262-277:
```dart
if (screenWidth > 1400) {
  crossAxisCount = 5; // Change this number
}
```

---

## 🎉 That's It!

Your menu system is **fully operational**. Just reload and start using it!

**Questions?** Check the full docs or explore the code - it's well-commented!
