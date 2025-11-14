# Token Refresh Implementation

**Date:** $(date)  
**Status:** ✅ Implemented

---

## Overview

Token refresh mechanism has been successfully implemented in the `ApiClient` class. Now, when a 401 (Unauthorized) error occurs, the app will attempt to refresh the access token using the refresh token before logging the user out.

---

## What Was Changed

### 1. Added Refresh Token Storage Key
**File:** `lib/core/constants/app_constants.dart`

Added constant for refresh token storage:
```dart
static const String refreshTokenKey = 'refresh_token';
```

### 2. Implemented Token Refresh Logic
**File:** `lib/core/network/api_client.dart`

#### Key Features:

1. **Automatic Token Refresh on 401**
   - When a 401 error occurs, the app attempts to refresh the token
   - Only logs out if refresh fails or no refresh token is available

2. **Concurrent Request Handling**
   - Prevents multiple simultaneous refresh requests
   - Queues pending requests during refresh
   - All pending requests are notified when refresh completes

3. **Infinite Loop Prevention**
   - Skips refresh if the failed request is already a refresh request
   - Uses separate Dio instance for refresh to avoid interceptor loops

4. **Automatic Request Retry**
   - After successful refresh, automatically retries the original request
   - Uses new token in the retry request

5. **Error Handling**
   - Handles various response formats (token, access_token, nested data)
   - Proper error logging in debug mode
   - Graceful fallback to logout on failure

---

## How It Works

### Flow Diagram

```
API Request → 401 Error
    ↓
Check if refresh request? → Yes → Logout
    ↓ No
Check if already refreshing? → Yes → Queue request
    ↓ No
Start refresh process
    ↓
Get refresh token from storage
    ↓
Call /auth/refresh endpoint
    ↓
Success? → Yes → Save new tokens → Retry original request
    ↓ No
Logout user
```

### Code Flow

1. **401 Error Detected** (`onError` interceptor)
   ```dart
   if (error.response?.statusCode == 401) {
     // Skip if already a refresh request
     if (error.requestOptions.path == AppConstants.refreshEndpoint) {
       await _handleUnauthorized();
       return;
     }
     
     // Attempt refresh
     final refreshed = await _attemptTokenRefresh();
     // ...
   }
   ```

2. **Token Refresh** (`_attemptTokenRefresh`)
   - Checks for concurrent refresh requests
   - Creates separate Dio instance (no interceptors)
   - Calls `/auth/refresh` endpoint
   - Parses response (supports multiple formats)
   - Saves new tokens to SharedPreferences

3. **Request Retry**
   - After successful refresh, retries original request
   - Uses new token in Authorization header
   - Handles retry failures appropriately

---

## Backend Response Format

The implementation supports multiple response formats:

### Format 1: Direct fields
```json
{
  "token": "new_access_token",
  "refresh_token": "new_refresh_token"
}
```

### Format 2: access_token field
```json
{
  "access_token": "new_access_token",
  "refresh_token": "new_refresh_token"
}
```

### Format 3: Nested in data
```json
{
  "data": {
    "token": "new_access_token",
    "refresh_token": "new_refresh_token"
  }
}
```

The code tries all these formats automatically.

---

## Usage

### For Login/Registration

When user logs in, make sure to save both tokens:

```dart
// After successful login
await sharedPreferences.setString(AppConstants.tokenKey, accessToken);
await sharedPreferences.setString(AppConstants.refreshTokenKey, refreshToken);
```

### Automatic Behavior

Once tokens are stored, the refresh mechanism works automatically:
- No code changes needed in repositories or data sources
- All API calls benefit from automatic token refresh
- User experience is seamless

---

## Testing

### Test Scenarios

1. **Normal Token Expiry**
   - Make API call with expired token
   - Should automatically refresh and retry
   - User should not be logged out

2. **Refresh Token Expired**
   - Make API call with expired access token
   - Refresh token also expired
   - Should logout user

3. **Concurrent Requests**
   - Multiple API calls fail with 401 simultaneously
   - Only one refresh request should be made
   - All requests should be retried after refresh

4. **Refresh Endpoint Failure**
   - Refresh endpoint returns error
   - Should logout user gracefully

5. **Network Error During Refresh**
   - Network failure during refresh
   - Should logout user

### Manual Testing

1. **Test with Expired Token:**
   ```dart
   // Set an expired token
   await sharedPreferences.setString(AppConstants.tokenKey, 'expired_token');
   
   // Make any API call
   final response = await apiClient.get('/menu/items');
   // Should automatically refresh and succeed
   ```

2. **Test Refresh Failure:**
   ```dart
   // Set invalid refresh token
   await sharedPreferences.setString(
     AppConstants.refreshTokenKey, 
     'invalid_refresh_token'
   );
   
   // Make API call with expired access token
   // Should logout user
   ```

---

## Debug Logging

The implementation includes comprehensive debug logging:

- `🔄 Attempting to refresh access token...` - Refresh started
- `✅ Token refreshed successfully` - Refresh succeeded
- `❌ Token refresh error: ...` - Refresh failed
- `⚠️ No refresh token available` - No refresh token found
- `❌ Retry failed with 401 after token refresh` - Retry failed

Enable debug mode to see these logs.

---

## Security Considerations

1. **Refresh Token Storage**
   - Currently stored in SharedPreferences (same as access token)
   - Consider using secure storage (e.g., `flutter_secure_storage`) for production

2. **Token Expiration**
   - No proactive token refresh (only on 401)
   - Consider implementing proactive refresh before expiration

3. **Refresh Token Rotation**
   - Implementation supports new refresh token from response
   - Backend should rotate refresh tokens for security

---

## Future Improvements

1. **Proactive Token Refresh**
   - Decode JWT to check expiration
   - Refresh before token expires (e.g., 5 minutes before)

2. **Secure Storage**
   - Move tokens to `flutter_secure_storage` for better security

3. **Token Refresh Events**
   - Emit events when token is refreshed
   - Allow UI to show "Refreshing session..." indicator

4. **Refresh Token Validation**
   - Validate refresh token format before using
   - Check expiration before attempting refresh

---

## Related Files

- `lib/core/network/api_client.dart` - Main implementation
- `lib/core/constants/app_constants.dart` - Constants
- `docs/API_BACKEND_ISSUES_ANALYSIS.md` - Original issue documentation

---

## Migration Notes

### For Existing Code

No changes required! The token refresh works automatically for all existing API calls.

### For New Login Implementation

Make sure to save both tokens:
```dart
await sharedPreferences.setString(AppConstants.tokenKey, accessToken);
await sharedPreferences.setString(AppConstants.refreshTokenKey, refreshToken);
```

---

**End of Document**

