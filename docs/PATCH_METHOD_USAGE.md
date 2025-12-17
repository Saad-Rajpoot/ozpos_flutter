# PATCH Method Usage Guide

**Date:** $(date)  
**Status:** ✅ Implemented

---

## Overview

The PATCH method is available in `ApiClient` for performing partial updates to resources. Unlike PUT which replaces the entire resource, PATCH allows you to update only specific fields.

---

## Implementation

### Location
`lib/core/network/api_client.dart` (lines 510-538)

### Method Signature
```dart
/// PATCH request
///
/// Used for partial updates to resources
Future<Response> patch(
  String path, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
  String? requestKey,
}) async
```

---

## Usage Examples

### Basic Usage

```dart
// Update only the status of an order
final response = await apiClient.patch(
  '/orders/123',
  data: {'status': 'completed'},
);
```

### Partial Update Example - Order Status

```dart
// In OrdersRemoteDataSource
Future<OrderEntity> updateOrderStatus(
  String orderId,
  String newStatus,
) async {
  try {
    final response = await _apiClient.patch(
      '${AppConstants.getOrdersEndpoint}/$orderId',
      data: {'status': newStatus},
    );
    final data = ExceptionHelper.validateResponseData(
      response.data,
      'updating order status',
    );
    return OrderModel.fromJson(data).toEntity();
  } catch (e) {
    throw ServerException(message: 'Failed to update order status');
  }
}
```

### Partial Update Example - Printer Settings

```dart
// In PrintingRemoteDataSource
Future<PrinterModel> updatePrinterSettings(
  String printerId, {
  String? name,
  bool? isDefault,
  String? connection,
}) async {
  try {
    // Only send fields that are provided
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (isDefault != null) updateData['is_default'] = isDefault;
    if (connection != null) updateData['connection'] = connection;

    final response = await apiClient.patch(
      '${AppConstants.getPrintersEndpoint}/$printerId',
      data: updateData,
    );
    
    final payload = ExceptionHelper.validateResponseData(
      response.data,
      'updating printer settings',
    );
    return PrinterModel.fromJson(payload);
  } catch (e) {
    throw ServerException(message: e.toString());
  }
}
```

### Partial Update Example - Combo Pricing

```dart
// In ComboRemoteDataSource
Future<ComboEntity> updateComboPricing(
  String comboId,
  ComboPricingEntity pricing,
) async {
  try {
    final response = await _apiClient.patch(
      '${AppConstants.updateComboEndpoint}/$comboId',
      data: {
        'pricing': ComboPricingModel.fromEntity(pricing).toJson(),
      },
    );
    final data = ExceptionHelper.validateResponseData(
      response.data,
      'updating combo pricing',
    );
    return ComboModel.fromJson(data).toEntity();
  } catch (e) {
    throw ServerException(message: 'Failed to update combo pricing');
  }
}
```

### Partial Update Example - Menu Item Price

```dart
// In MenuRemoteDataSource
Future<MenuItemModel> updateMenuItemPrice(
  String itemId,
  double newPrice,
) async {
  try {
    final response = await apiClient.patch(
      '${AppConstants.getMenuItemsEndpoint}/$itemId',
      data: {'price': newPrice},
    );
    final payload = ExceptionHelper.validateResponseData(
      response.data,
      'updating menu item price',
    );
    return MenuItemModel.fromJson(payload);
  } catch (e) {
    throw ServerException(message: 'Failed to update menu item price');
  }
}
```

---

## When to Use PATCH vs PUT

### Use PATCH when:
- ✅ Updating only specific fields
- ✅ Partial updates (e.g., status, price, settings)
- ✅ Backend expects partial updates
- ✅ You want to minimize data transfer
- ✅ Updating nested properties

### Use PUT when:
- ✅ Replacing the entire resource
- ✅ Full resource updates
- ✅ Backend requires complete resource representation
- ✅ Creating or replacing a resource (idempotent)

---

## Best Practices

### 1. Only Send Changed Fields
```dart
// ✅ Good - Only send what changed
final updateData = <String, dynamic>{};
if (name != null) updateData['name'] = name;
if (price != null) updateData['price'] = price;

await apiClient.patch('/resource/123', data: updateData);

// ❌ Bad - Sending entire object
await apiClient.patch('/resource/123', data: fullObject.toJson());
```

### 2. Handle Null Values Properly
```dart
// ✅ Good - Check for null before adding
if (optionalField != null) {
  updateData['optional_field'] = optionalField;
}

// ❌ Bad - Sending null values
updateData['optional_field'] = optionalField; // Could be null
```

### 3. Use Meaningful Error Messages
```dart
try {
  final response = await apiClient.patch(...);
  // Handle success
} catch (e) {
  throw ServerException(
    message: 'Failed to update order status: ${e.toString()}',
  );
}
```

### 4. Validate Response
```dart
final payload = ExceptionHelper.validateResponseData(
  response.data,
  'updating resource',
);
```

---

## Comparison: PATCH vs PUT

| Feature | PATCH | PUT |
|---------|-------|-----|
| **Purpose** | Partial update | Full replacement |
| **Data Sent** | Only changed fields | Entire resource |
| **Idempotent** | May not be | Yes |
| **Use Case** | Status updates, settings | Complete resource updates |
| **Network** | Less data transfer | More data transfer |

---

## Common Use Cases

### 1. Status Updates
```dart
// Order status
await apiClient.patch('/orders/123', data: {'status': 'completed'});

// Table status
await apiClient.patch('/tables/5', data: {'status': 'occupied'});
```

### 2. Settings Updates
```dart
// Printer settings
await apiClient.patch('/printers/1', data: {
  'is_default': true,
  'connection': 'network',
});
```

### 3. Price Updates
```dart
// Menu item price
await apiClient.patch('/menu-items/42', data: {'price': 15.99});
```

### 4. Nested Property Updates
```dart
// Update combo pricing only
await apiClient.patch('/combos/10', data: {
  'pricing': {
    'mode': 'fixed',
    'fixed_price': 25.00,
  },
});
```

---

## Error Handling

```dart
try {
  final response = await apiClient.patch(
    '/resource/123',
    data: updateData,
  );
  
  // Validate response
  final payload = ExceptionHelper.validateResponseData(
    response.data,
    'updating resource',
  );
  
  // Process response
  return Model.fromJson(payload);
  
} on DioException catch (e) {
  // Handle network/HTTP errors
  throw ExceptionHelper.handleDioException(e, 'updating resource');
} catch (e) {
  // Handle other errors
  if (e is ServerException || e is NetworkException) {
    rethrow;
  }
  throw ServerException(
    message: 'Unexpected error updating resource: $e',
  );
}
```

---

## Testing

### Unit Test Example
```dart
test('should update order status using PATCH', () async {
  // Arrange
  when(mockApiClient.patch(
    any,
    data: anyNamed('data'),
  )).thenAnswer((_) async => Response(
    data: {'id': '123', 'status': 'completed'},
    statusCode: 200,
    requestOptions: RequestOptions(path: ''),
  ));

  // Act
  final result = await dataSource.updateOrderStatus('123', 'completed');

  // Assert
  expect(result.status, 'completed');
  verify(mockApiClient.patch(
    '/orders/123',
    data: {'status': 'completed'},
  )).called(1);
});
```

---

## Summary

✅ **PATCH method is available** in `ApiClient`  
✅ **Use for partial updates** - only send changed fields  
✅ **Better performance** - less data transfer  
✅ **Follow REST conventions** - PATCH for partial, PUT for full  

---

**End of Document**

