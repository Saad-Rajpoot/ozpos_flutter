# API & Backend Interaction Issues Analysis

**Date:** $(date)  
**Scope:** REST APIs, GraphQL, JSON Parsing, Authentication, WebSockets, Error Handling, Retry Logic, Pagination & Caching

---

## Executive Summary

This document identifies critical issues and gaps in the API & Backend interaction layer of the OzPOS Flutter application. While the foundation is solid with Dio-based REST API client, several important features are missing or incomplete.

---

## 1. REST APIs ✅ (Mostly Good)

### Current Implementation
- ✅ **HTTP Client**: Using Dio with proper configuration
- ✅ **Base URL**: Environment-based configuration via `AppConfig`
- ✅ **Request Methods**: GET, POST, PUT, DELETE all implemented
- ✅ **Request Cancellation**: CancelToken tracking implemented
- ✅ **Headers**: Content-Type and Accept headers properly set

### Issues Found

#### 🔴 **Critical: Missing PATCH Method**
- **Location**: `lib/core/network/api_client.dart`
- **Issue**: No PATCH method implementation
- **Impact**: Cannot perform partial updates if backend requires PATCH
- **Recommendation**: Add PATCH method similar to PUT

```dart
/// PATCH request
Future<Response> patch(
  String path, {
  dynamic data,
  Map<String, dynamic>? queryParameters,
  Options? options,
  CancelToken? cancelToken,
  String? requestKey,
}) async {
  // Implementation needed
}
```

#### ⚠️ **Medium: Query Parameter Building**
- **Location**: Multiple data sources (e.g., `menu_remote_datasource.dart:54`)
- **Issue**: Manual string concatenation for query parameters
- **Example**: `'${AppConstants.getMenuItemsEndpoint}?category_id=$categoryId'`
- **Impact**: Error-prone, no URL encoding, difficult to maintain
- **Recommendation**: Use Dio's `queryParameters` map instead

**Current (Bad):**
```dart
final response = await apiClient.get(
  '${AppConstants.getMenuItemsEndpoint}?category_id=$categoryId',
);
```

**Should be:**
```dart
final response = await apiClient.get(
  AppConstants.getMenuItemsEndpoint,
  queryParameters: {'category_id': categoryId},
);
```

---

## 2. GraphQL ❌ (Not Implemented)

### Current Status
- ❌ **No GraphQL Support**: No GraphQL client or queries found
- ❌ **No GraphQL Packages**: No `graphql` or `ferry` packages in `pubspec.yaml`

### Issues Found

#### 🔴 **Critical: GraphQL Not Available**
- **Location**: Entire codebase
- **Issue**: PRD mentions GraphQL as optional but no implementation exists
- **Impact**: Cannot use GraphQL APIs if backend provides them
- **Recommendation**: 
  - If needed, add `graphql` package
  - Create `GraphQLClient` wrapper similar to `ApiClient`
  - Implement query/mutation builders

---

## 3. JSON Parsing ✅ (Good with Minor Issues)

### Current Implementation
- ✅ **Serialization**: Using `fromJson`/`toJson` pattern consistently
- ✅ **Model Pattern**: Models properly convert to/from entities
- ✅ **Error Handling**: ExceptionHelper validates response structure

### Issues Found

#### ⚠️ **Medium: Inconsistent Response Validation**
- **Location**: Multiple data sources
- **Issue**: Some use `validateListResponse`, others use `validateResponseData` with different `dataKey` defaults
- **Example**: 
  - `menu_remote_datasource.dart` uses `validateListResponse` (defaults to 'data')
  - Some might expect different response structures
- **Impact**: Potential runtime errors if backend response format differs
- **Recommendation**: Standardize response format or make dataKey configurable per endpoint

#### ⚠️ **Low: No JSON Schema Validation**
- **Issue**: No runtime validation of JSON structure against expected schema
- **Impact**: Type errors only caught at runtime
- **Recommendation**: Consider using `json_serializable` with validation or `json_schema` package

---

## 4. Authentication ⚠️ (Partially Implemented)

### Current Implementation
- ✅ **JWT Token Storage**: Using SharedPreferences with key 'token'
- ✅ **Bearer Token**: Authorization header properly set
- ✅ **401 Handling**: Unauthorized errors trigger logout
- ⚠️ **Token Refresh**: Endpoint exists but not implemented

### Issues Found

#### 🔴 **Critical: No Token Refresh Mechanism**
- **Location**: `lib/core/network/api_client.dart:122-126`
- **Issue**: On 401, app immediately logs out instead of attempting token refresh
- **Code Reference**:
```dart
onError: (error, handler) async {
  if (error.response?.statusCode == 401) {
    // Handle token refresh or logout
    // Don't retry on 401 errors - handle immediately
    await _handleUnauthorized(); // ❌ Just logs out, no refresh attempt
  }
  handler.next(error);
},
```
- **Impact**: Users get logged out unnecessarily when token expires
- **Recommendation**: Implement token refresh flow:
  1. On 401, attempt refresh using refresh token
  2. If refresh succeeds, retry original request with new token
  3. Only logout if refresh fails or no refresh token available

**Recommended Implementation:**
```dart
onError: (error, handler) async {
  if (error.response?.statusCode == 401) {
    final refreshToken = _sharedPreferences.getString('refresh_token');
    if (refreshToken != null) {
      try {
        // Attempt token refresh
        final refreshResponse = await _dio.post(
          AppConstants.refreshEndpoint,
          data: {'refresh_token': refreshToken},
        );
        final newToken = refreshResponse.data['token'];
        await _sharedPreferences.setString(AppConstants.tokenKey, newToken);
        
        // Retry original request with new token
        error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(error.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // Refresh failed, logout
        await _handleUnauthorized();
      }
    } else {
      await _handleUnauthorized();
    }
  }
  handler.next(error);
},
```

#### ⚠️ **Medium: No Token Expiration Check**
- **Issue**: App doesn't check token expiration before making requests
- **Impact**: Unnecessary failed requests when token is expired
- **Recommendation**: Decode JWT and check expiration, refresh proactively

#### ⚠️ **Low: No OAuth/Firebase Auth Support**
- **Issue**: Only JWT/Bearer token authentication implemented
- **Impact**: Cannot integrate with OAuth providers or Firebase Auth
- **Recommendation**: Add authentication abstraction layer to support multiple auth methods

---

## 5. WebSockets ❌ (Not Implemented)

### Current Status
- ❌ **No WebSocket Client**: No WebSocket implementation found
- ❌ **No Real-time Features**: Despite PRD mentioning Laravel Echo/SSE for real-time updates

### Issues Found

#### 🔴 **Critical: Real-time Features Missing**
- **Location**: Entire codebase
- **Issue**: PRD specifies "Laravel Echo/SSE (or Pusher/Redis) channels for order status, KDS lanes, dispatch/driver ticks"
- **Impact**: No real-time updates for:
  - Order status changes
  - KDS (Kitchen Display System) lanes
  - Dispatch/driver location updates
  - Printer webhooks
- **Recommendation**: 
  1. Add WebSocket/SSE client (e.g., `web_socket_channel` or `sse_client`)
  2. Create `RealtimeService` for managing connections
  3. Implement channel subscriptions for:
     - Order updates: `orders.{orderId}`
     - KDS lanes: `kds.lane.{laneId}`
     - Dispatch: `dispatch.{jobId}`
     - Printers: `printers.{printerId}`

**Example Implementation Structure:**
```dart
class RealtimeService {
  WebSocketChannel? _channel;
  
  void subscribeToOrder(String orderId, Function(OrderUpdate) callback) {
    _channel?.sink.add(jsonEncode({
      'event': 'subscribe',
      'channel': 'orders.$orderId',
    }));
  }
  
  void subscribeToKDSLane(String laneId, Function(KDSUpdate) callback) {
    // Implementation
  }
}
```

---

## 6. Error Handling ✅ (Well Implemented)

### Current Implementation
- ✅ **Exception Hierarchy**: Proper exception types (NetworkException, ServerException, etc.)
- ✅ **ExceptionHelper**: Centralized error handling utility
- ✅ **RepositoryErrorHandler**: Standardized error-to-failure conversion
- ✅ **User-Friendly Messages**: Error messages are user-safe

### Issues Found

#### ⚠️ **Low: Error Response Parsing**
- **Issue**: Not parsing server error response body for detailed error messages
- **Impact**: Generic error messages instead of server-provided details
- **Recommendation**: Parse error response body if available:
```dart
if (e.response?.data is Map<String, dynamic>) {
  final errorData = e.response!.data;
  final message = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
  return ServerException(message: message);
}
```

---

## 7. Retry Logic ✅ (Good but Can Be Improved)

### Current Implementation
- ✅ **RetryInterceptor**: Well-implemented retry mechanism
- ✅ **Configurable**: Max retries and delay configurable
- ✅ **Smart Retry**: Only retries on appropriate errors (network, 5xx, 408, 429)
- ⚠️ **Exponential Backoff**: Available but disabled by default

### Issues Found

#### ⚠️ **Medium: Exponential Backoff Disabled**
- **Location**: `lib/core/network/api_client.dart:101`
- **Issue**: `useExponentialBackoff: false` - using fixed delay
- **Code**:
```dart
RetryInterceptor(
  maxRetries: AppConstants.maxRetries,
  retryDelay: AppConstants.retryDelay,
  useExponentialBackoff: false, // ❌ Should be true for production
  dio: _dio,
),
```
- **Impact**: Fixed 1-second delay between retries can overwhelm server
- **Recommendation**: Enable exponential backoff for production:
```dart
useExponentialBackoff: AppConfig.instance.environment == AppEnvironment.production,
```

#### ⚠️ **Low: No Jitter in Retry Delay**
- **Issue**: Retry delays are deterministic
- **Impact**: Thundering herd problem if multiple clients retry simultaneously
- **Recommendation**: Add random jitter to retry delays

---

## 8. Pagination ⚠️ (Constants Defined but Not Used)

### Current Status
- ✅ **Constants Defined**: `defaultPageSize = 20`, `maxPageSize = 100` in `AppConstants`
- ❌ **Not Implemented**: No pagination parameters in API calls

### Issues Found

#### 🔴 **Critical: Pagination Not Implemented**
- **Location**: All data sources (e.g., `menu_remote_datasource.dart`, `combo_remote_datasource.dart`)
- **Issue**: All list endpoints fetch all data without pagination
- **Examples**:
  - `getMenuItems()` - fetches all items
  - `getCombos()` - fetches all combos
  - `getOrders()` - fetches all orders
- **Impact**: 
  - Poor performance with large datasets
  - High memory usage
  - Slow initial load times
  - Potential API rate limiting
- **Recommendation**: Implement pagination support:

**1. Create Pagination Model:**
```dart
class PaginationParams {
  final int page;
  final int limit;
  
  const PaginationParams({
    this.page = 1,
    this.limit = AppConstants.defaultPageSize,
  });
  
  Map<String, dynamic> toQueryParams() => {
    'page': page,
    'limit': limit.clamp(1, AppConstants.maxPageSize),
  };
}

class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNextPage;
  final bool hasPreviousPage;
}
```

**2. Update Data Sources:**
```dart
Future<PaginatedResponse<MenuItemModel>> getMenuItems({
  PaginationParams? pagination,
}) async {
  final params = pagination?.toQueryParams() ?? {};
  final response = await apiClient.get(
    AppConstants.getMenuItemsEndpoint,
    queryParameters: params,
  );
  // Parse paginated response
}
```

**3. Update Repositories:**
```dart
Future<Either<Failure, PaginatedResponse<MenuItemEntity>>> getMenuItems({
  PaginationParams? pagination,
}) async {
  // Implementation
}
```

---

## 9. Caching Strategies ⚠️ (Partially Implemented)

### Current Status
- ✅ **Constants Defined**: `cacheExpiration = Duration(hours: 1)`, `maxCacheSize = 100`
- ✅ **Local Caching**: SQLite used for local data storage
- ❌ **HTTP Cache Headers**: Not utilized

### Issues Found


**1. Store ETags:**
```dart
class CacheManager {
  final SharedPreferences _prefs;
  
  Future<String?> getETag(String url) async {
    return _prefs.getString('etag_$url');
  }
  
  Future<void> setETag(String url, String etag) async {
    await _prefs.setString('etag_$url', etag);
  }
}
```


#### ⚠️ **Medium: No Cache-Control Header Handling**
- **Issue**: Not respecting Cache-Control headers from server
- **Impact**: Caching decisions not aligned with server recommendations
- **Recommendation**: Parse and respect Cache-Control headers

#### ⚠️ **Medium: No Last-Modified Support**
- **Issue**: Not using Last-Modified/If-Modified-Since headers
- **Impact**: Missing another optimization opportunity
- **Recommendation**: Implement Last-Modified header support similar to ETag

#### ⚠️ **Low: Cache Size Management**
- **Issue**: `maxCacheSize = 100` constant exists but not enforced
- **Impact**: Cache can grow unbounded
- **Recommendation**: Implement LRU cache eviction policy

---

## Summary of Issues by Priority

### 🔴 Critical (Must Fix)
1. **No Token Refresh Mechanism** - Users get logged out unnecessarily
2. **Pagination Not Implemented** - Performance issues with large datasets
4. **WebSockets/Real-time Missing** - Core feature from PRD not implemented
5. **Missing PATCH Method** - Cannot perform partial updates

### ⚠️ Medium (Should Fix)
1. **Exponential Backoff Disabled** - Can overwhelm server
2. **Query Parameter Building** - Error-prone string concatenation
3. **No Cache-Control Handling** - Not respecting server cache directives
4. **No Last-Modified Support** - Missing optimization opportunity
5. **Inconsistent Response Validation** - Potential runtime errors

### ⚠️ Low (Nice to Have)
1. **No Jitter in Retry Delay** - Thundering herd potential
2. **No Token Expiration Check** - Unnecessary failed requests
3. **No OAuth/Firebase Auth** - Limited authentication options
4. **No JSON Schema Validation** - Type errors only at runtime
5. **Cache Size Not Enforced** - Unbounded cache growth

---

## Recommendations

### Immediate Actions (Sprint 1)
1. Implement token refresh mechanism
2. Add pagination support to all list endpoints
3. Enable exponential backoff for production
4. Fix query parameter building to use Dio's queryParameters

### Short-term (Sprint 2-3)
2. Add WebSocket/SSE client for real-time features
3. Add PATCH method to ApiClient
4. Standardize response validation

### Long-term (Future Sprints)
1. Add GraphQL support (if needed)
2. Implement OAuth/Firebase Auth
3. Add cache size management (LRU)
4. Add JSON schema validation
5. Implement Last-Modified header support

---

## Testing Recommendations

1. **Token Refresh**: Test refresh flow with expired tokens
2. **Pagination**: Test with large datasets (1000+ items)
3. **Retry Logic**: Test with network failures and server errors
5. **WebSockets**: Test connection handling and reconnection logic

---

## Related Files

- `lib/core/network/api_client.dart` - Main API client
- `lib/core/network/retry_interceptor.dart` - Retry logic
- `lib/core/utils/exception_helper.dart` - Error handling
- `lib/core/constants/app_constants.dart` - Constants
- `lib/features/*/data/datasources/*_remote_datasource.dart` - Data sources

---

**End of Report**

