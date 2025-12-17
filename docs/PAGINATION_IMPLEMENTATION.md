# Pagination Implementation

**Date:** $(date)  
**Status:** ✅ Implemented

---

## Overview

Pagination support has been successfully implemented across the codebase. This allows efficient handling of large datasets by fetching data in pages rather than loading everything at once.

---

## What Was Implemented

### 1. Core Pagination Models

#### `PaginationParams` (`lib/core/models/pagination_params.dart`)
- **Purpose**: Parameters for paginated API requests
- **Features**:
  - Page number (1-indexed)
  - Items per page (limit)
  - Optional sorting (sortBy, sortOrder)
  - Automatic limit clamping to `maxPageSize`
  - Helper methods: `nextPage()`, `previousPage()`, `withLimit()`
  - Converts to query parameters map

**Example:**
```dart
final params = PaginationParams(
  page: 1,
  limit: 20,
  sortBy: 'name',
  sortOrder: 'asc',
);

// Convert to query params
final queryParams = params.toQueryParams();
// {page: 1, limit: 20, sort_by: 'name', sort_order: 'asc'}
```

#### `PaginatedResponse<T>` (`lib/core/models/paginated_response.dart`)
- **Purpose**: Wrapper for paginated API responses
- **Features**:
  - Generic type support
  - Current page, total pages, total items
  - Helper properties: `hasNextPage`, `hasPreviousPage`, `isFirstPage`, `isLastPage`
  - Supports multiple API response formats
  - Can combine responses (for appending next page)

**Example:**
```dart
final response = PaginatedResponse<MenuItemModel>(
  data: items,
  currentPage: 1,
  totalPages: 5,
  totalItems: 100,
  perPage: 20,
);

if (response.hasNextPage) {
  // Load next page
}
```

### 2. ExceptionHelper Enhancement

Added `validatePaginatedResponse<T>()` method to handle paginated API responses with proper error handling and support for different response formats.

### 3. Menu Data Source Updates

**File:** `lib/features/menu/data/datasources/menu_remote_datasource.dart`

Added paginated versions of all list methods:
- `getMenuItemsPaginated()`
- `getMenuItemsByCategoryPaginated()`
- `getMenuCategoriesPaginated()`
- `searchMenuItemsPaginated()`
- `getPopularMenuItemsPaginated()`

**Key Improvements:**
- ✅ Fixed query parameter building (no more string concatenation)
- ✅ Uses Dio's `queryParameters` map
- ✅ Backward compatible (old methods still work)

### 4. Mock Data Source Support

**File:** `lib/features/menu/data/datasources/menu_mock_datasource.dart`

All paginated methods implemented with proper pagination logic for testing.

---

## Usage Examples

### Basic Pagination

```dart
// Get first page with default size (20 items)
final response = await menuDataSource.getMenuItemsPaginated();

print('Page ${response.currentPage} of ${response.totalPages}');
print('Total items: ${response.totalItems}');
print('Items in this page: ${response.data.length}');
```

### Custom Pagination

```dart
// Get page 2 with 50 items per page
final params = PaginationParams(page: 2, limit: 50);
final response = await menuDataSource.getMenuItemsPaginated(
  pagination: params,
);
```

### Next Page

```dart
// Get next page
final currentParams = PaginationParams(page: 1, limit: 20);
final nextParams = currentParams.nextPage(); // page: 2

final nextPage = await menuDataSource.getMenuItemsPaginated(
  pagination: nextParams,
);
```

### Search with Pagination

```dart
final params = PaginationParams(page: 1, limit: 10);
final results = await menuDataSource.searchMenuItemsPaginated(
  'pizza',
  pagination: params,
);
```

### Combining Pages (Infinite Scroll)

```dart
PaginatedResponse<MenuItemModel>? allItems;

// Load first page
var currentPage = await menuDataSource.getMenuItemsPaginated(
  pagination: PaginationParams(page: 1),
);
allItems = currentPage;

// Load and append next pages
while (currentPage.hasNextPage) {
  final nextPage = await menuDataSource.getMenuItemsPaginated(
    pagination: currentPage.currentPage + 1,
  );
  allItems = allItems!.combine(nextPage);
  currentPage = nextPage;
}
```

---

## Backend Response Format

The implementation supports multiple response formats:

### Format 1: Laravel-style (default)
```json
{
  "data": [...],
  "current_page": 1,
  "last_page": 5,
  "total": 100,
  "per_page": 20
}
```

### Format 2: Alternative keys
```json
{
  "data": [...],
  "currentPage": 1,
  "totalPages": 5,
  "totalItems": 100,
  "perPage": 20
}
```

The `PaginatedResponse.fromJson()` factory automatically tries multiple key variations.

---

## Integration with Repositories

### Current Status
- ✅ Data sources support pagination
- ⚠️ Repository interfaces need to be updated (optional)
- ⚠️ BLoC/UI layers can use paginated methods directly

### Recommended Repository Update

```dart
abstract class MenuRepository {
  // Keep old method for backward compatibility
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems();
  
  // Add paginated version
  Future<Either<Failure, PaginatedResponse<MenuItemEntity>>> getMenuItemsPaginated({
    PaginationParams? pagination,
  });
}
```

---

## Benefits

1. **Performance**
   - Reduced initial load time
   - Lower memory usage
   - Faster API responses

2. **User Experience**
   - Faster app startup
   - Smooth scrolling with pagination
   - Better for large datasets

3. **Network Efficiency**
   - Less data transfer
   - Reduced server load
   - Better for mobile networks

4. **Scalability**
   - Works with datasets of any size
   - No performance degradation with growth

---

## Migration Guide

### For Existing Code

**No changes required!** Old methods still work:
```dart
// Still works
final items = await menuDataSource.getMenuItems();
```

### For New Code

Use paginated methods:
```dart
// Recommended for new code
final response = await menuDataSource.getMenuItemsPaginated();
final items = response.data;
```

### Gradual Migration

1. Keep using old methods for now
2. Update new features to use pagination
3. Gradually migrate existing features
4. Eventually deprecate old methods (optional)

---

## Constants

Pagination constants are defined in `AppConstants`:
```dart
static const int defaultPageSize = 20;
static const int maxPageSize = 100;
```

These can be adjusted based on your needs.

---

## Testing

### Unit Tests

```dart
test('should return paginated menu items', () async {
  final params = PaginationParams(page: 1, limit: 10);
  final response = await dataSource.getMenuItemsPaginated(
    pagination: params,
  );
  
  expect(response.data.length, lessThanOrEqualTo(10));
  expect(response.currentPage, 1);
  expect(response.totalItems, greaterThan(0));
});
```

### Integration Tests

Test with real API to verify:
- Correct query parameters sent
- Response parsing works
- Pagination metadata is correct

---

## Future Enhancements

1. **Repository Layer**
   - Add paginated methods to repository interfaces
   - Update repository implementations

2. **UI Components**
   - Pagination widget
   - Infinite scroll helper
   - Page navigation controls

3. **Caching**
   - Cache paginated responses
   - Smart cache invalidation

4. **Sorting & Filtering**
   - Enhanced sorting support
   - Filter integration with pagination

---

## Related Files

- `lib/core/models/pagination_params.dart` - Pagination parameters
- `lib/core/models/paginated_response.dart` - Paginated response wrapper
- `lib/core/utils/exception_helper.dart` - Pagination validation
- `lib/core/constants/app_constants.dart` - Pagination constants
- `lib/features/menu/data/datasources/menu_remote_datasource.dart` - Implementation
- `lib/features/menu/data/datasources/menu_mock_datasource.dart` - Mock implementation

---

## Notes

- ✅ Backward compatible - old methods still work
- ✅ Type-safe with generics
- ✅ Supports multiple API response formats
- ✅ Comprehensive error handling
- ✅ Well-documented code

---

**End of Document**

