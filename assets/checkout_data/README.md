# Checkout Data Assets

This directory contains JSON data files for the checkout feature, following the same pattern as other features in the project.

## Files Overview

### 📋 Main Data Files

#### `orders_data.json`
- **Purpose**: Complete order history with payment details
- **Contains**: 
  - Order information (ID, customer, table, items)
  - Payment details (method, amounts, tips, discounts)
  - Tender information for split payments
  - Voucher applications
  - Order status and timestamps
- **Use Case**: Order management, history, analytics

#### `payment_methods.json`
- **Purpose**: Available payment methods and configuration
- **Contains**:
  - Payment method definitions (cash, card, wallet, BNPL)
  - Split payment options
  - Quick amount buttons
  - Tip and discount options
- **Use Case**: Payment method selection, UI configuration

#### `vouchers_data.json`
- **Purpose**: Voucher codes and loyalty program data
- **Contains**:
  - Voucher definitions (codes, amounts, validity)
  - Loyalty program configuration
  - Usage statistics
- **Use Case**: Discount application, loyalty management

#### `transactions_data.json`
- **Purpose**: Transaction history and payment processing
- **Contains**:
  - Individual transaction records
  - Daily summary statistics
  - Payment method breakdown
  - Error handling data
- **Use Case**: Payment processing, reporting, analytics

### ⚠️ Error Files

#### `*_error.json` files
- **Purpose**: Error handling and fallback data
- **Pattern**: Each main data file has a corresponding error file
- **Contains**: Error details and fallback data for offline scenarios
- **Use Case**: Graceful degradation, offline support

## Data Structure

### Order Structure
```json
{
  "id": "order_001",
  "orderId": "ORD-1703123456789",
  "customerName": "John Doe",
  "tableNumber": "T-05",
  "orderType": "dineIn|takeaway|delivery",
  "items": [...],
  "payment": {...},
  "tenders": [...],
  "vouchers": [...],
  "status": "completed|pending|cancelled",
  "createdAt": "2023-12-21T10:25:00Z",
  "completedAt": "2023-12-21T10:30:00Z"
}
```

### Payment Structure
```json
{
  "method": "cash|card|wallet|bnpl",
  "subtotal": 31.97,
  "tipAmount": 3.20,
  "tipPercent": 10,
  "discountAmount": 0.00,
  "discountPercent": 0,
  "voucherTotal": 0.00,
  "loyaltyRedemption": 0.00,
  "tax": 3.52,
  "totalBeforeTax": 35.17,
  "grandTotal": 38.69,
  "cashReceived": 40.00,
  "change": 1.31
}
```

### Voucher Structure
```json
{
  "id": "voucher_001",
  "code": "SAVE5",
  "name": "Save $5",
  "type": "fixed_amount|percentage",
  "value": 5.00,
  "description": "Get $5 off your order",
  "minOrderAmount": 25.00,
  "maxDiscount": 5.00,
  "validFrom": "2023-12-01T00:00:00Z",
  "validUntil": "2024-01-31T23:59:59Z",
  "usageLimit": 100,
  "usedCount": 23,
  "enabled": true
}
```

## Usage in Code

### Loading Data
```dart
// Load orders data
final ordersData = await loadJsonAsset('assets/checkout_data/orders_data.json');

// Load payment methods
final paymentMethods = await loadJsonAsset('assets/checkout_data/payment_methods.json');

// Load vouchers
final vouchers = await loadJsonAsset('assets/checkout_data/vouchers_data.json');
```

### Error Handling
```dart
try {
  final data = await loadJsonAsset('assets/checkout_data/orders_data.json');
} catch (e) {
  // Fallback to error data
  final errorData = await loadJsonAsset('assets/checkout_data/orders_data_error.json');
}
```

## Integration with Checkout Feature

These JSON files support the checkout feature's `saveOrder` functionality by providing:

1. **Order Templates**: Sample order structures for testing
2. **Payment Configuration**: Available payment methods and options
3. **Voucher System**: Discount codes and validation rules
4. **Transaction History**: Payment processing records
5. **Error Scenarios**: Fallback data for offline scenarios

## Data Relationships

```
Orders ←→ Transactions (1:many)
Orders ←→ Vouchers (many:many)
Orders ←→ Payment Methods (many:1)
Transactions ←→ Tenders (1:1)
```

## Maintenance

- Update data files when adding new payment methods
- Add new voucher codes as needed
- Maintain error files for offline scenarios
- Keep transaction history for reporting
- Update order statuses as needed

## Notes

- All timestamps are in ISO 8601 format
- Amounts are in the base currency (dollars)
- IDs are unique across the system
- Error files provide graceful degradation
- Data follows the same pattern as other feature assets
