## Purpose

- Document how authentication actually works in this Flutter POS app.
- Help future developers quickly see:
  - Where login/logout are implemented.
  - What APIs are called and with which payloads.
  - How tokens and user data are stored and later reused.
  - How routes are protected and how sessions/timeouts are handled.

---

## Entry points

- **App bootstrap**
  - `lib/main.dart`
    - Registers `AuthCubit` via DI (`CoreModule.init`).
    - Wraps `MaterialApp` with:
      - `BlocProvider<AuthCubit>.value(value: authCubit)`
      - `BlocListener<AuthCubit, AuthState>` to react to auth status changes.
    - Initial route is `AppRouter.splash` (`/splash`).

- **Splash / initial session check**
  - `lib/core/navigation/app_router.dart`
    - Route `/splash` → `AuthSplashScreen` (`features/auth/presentation/screens/auth_splash_screen.dart`).
  - `AuthCubit` constructor (`core/auth/auth_cubit.dart`) calls `_initialize()`, which:
    - Checks existing session via `AuthRepository.hasActiveSession()`.
    - Emits:
      - `AuthState.authenticated()` if a token exists.
      - `AuthState.unauthenticated()` otherwise.

- **Login screen**
  - `lib/features/auth/presentation/screens/login_screen.dart`
    - Triggered by:
      - Route guard in `AppRouter.generateRoute` when a protected route is hit and `AuthCubit.state.isAuthenticated == false`.
      - Direct `/login` route.
    - When user taps **Sign In**, calls `AuthCubit.login(email, password)`.

- **Logout**
  - Logout button in dashboard:
    - `features/dashboard/presentation/screens/dashboard_screen.dart`
      - `context.read<AuthCubit>().logout();`

---

## High-level auth flow

- **On app start**
  - `AuthCubit` checks **secure storage** for an access token via `AuthRepository.hasActiveSession()`.
  - If token exists → state = `authenticated`.
  - If not → state = `unauthenticated`.

- **Route guard**
  - `AppRouter` considers all routes **protected** except:
    - `/splash`
    - `/login`
  - For protected routes, if `AuthCubit.state.isAuthenticated == false`:
    - Redirects to `/login` (with any `state.message` passed as `initialMessage`).

- **Login**
  - `LoginScreen` validates email/password.
  - Calls `AuthCubit.login(email, password)`:
    - Emits loading state.
    - Calls `AuthRepository.login(...)`.
    - On success:
      - Saves token + user/vendor/branch info to `SecureStorageService` and `SharedPreferences`.
      - Emits `AuthState.authenticated()`.
    - On error:
      - Emits `AuthState` with `status=unauthenticated` + `errorMessage`.

- **Authenticated navigation**
  - `main.dart` listens to `AuthCubit`:
    - On `AuthStatus.authenticated`:
      - Starts `SessionTimeoutManager`.
      - Navigates to `/dashboard` if not already there.
    - On `AuthStatus.unauthenticated` or `locked`:
      - Stops timeout manager.
      - Navigates to `/login`.

- **Logout / 401 handling**
  - Explicit logout:
    - Calls logout API, then clears tokens + user info and sets state to unauthenticated.
  - Failed API with 401:
    - `ApiClient._handleUnauthorized()`:
      - Clears tokens + user data.
      - Notifies `AuthCubit.handleUnauthorized(...)`.
      - Navigates to `/login` with a “Session expired” message.

---

## Mermaid flowchart

```mermaid
flowchart TD
  A[App start] --> B[AuthCubit._initialize()]
  B --> C{SecureStorage\nhas access token?}
  C -- Yes --> D[AuthState.authenticated]
  C -- No --> E[AuthState.unauthenticated]

  D --> F[MaterialApp / Protected routes available]
  E --> G[/splash -> /login via route guard]

  G --> H[User enters email/password\nLoginScreen._submit]
  H --> I[AuthCubit.login]
  I --> J[AuthRepository.login -> AuthRemoteDataSource.login]
  J --> K[POST auth/login\n+ save token & user data]
  K --> L[AuthState.authenticated]
  L --> F

  F --> M[User taps Logout]
  M --> N[AuthCubit.logout]
  N --> O[AuthRepository.logout\nPOST auth/logout\n+ clear tokens/user]
  O --> P[AuthState.unauthenticated]
  P --> G

  F --> Q[API call via ApiClient]
  Q --> R{401 Unauthorized\n+ refresh failed?}
  R -- Yes --> S[_handleUnauthorized]\nclear tokens,user\nAuthCubit.handleUnauthorized\n-> /login
  R -- No --> T[Continue with new token]
```

---

## Step-by-step detailed flow

### 1. App bootstrap & session check

- **File**: `lib/main.dart`
- `main()`:
  - Initializes DI (`di.init()`), theme, Sentry, etc.
  - Creates `AuthCubit` via DI:
    - See `lib/core/di/modules/core_module.dart`:
      - Registers:
        - `AuthRemoteDataSourceImpl` with `Dio`.
        - `SecureStorageService`.
        - `AuthRepository`.
        - `AuthCubit(authRepository: sl())`.
  - Wraps `MaterialApp` in:
    - `BlocProvider<AuthCubit>.value(value: authCubit)`.
    - `BlocListener<AuthCubit, AuthState>`:
      - On `authenticated`:
        - `SessionTimeoutManager.instance.start()`.
        - Navigates to `/dashboard`.
      - On `unauthenticated` or `locked`:
        - `SessionTimeoutManager.instance.stop()`.
        - Navigates to `/login`.

- **File**: `lib/core/auth/auth_cubit.dart`
  - Constructor:
    - Calls `_initialize()`:
      - `hasSession = await _authRepository.hasActiveSession();`
      - If `true` → `emit(AuthState.authenticated());`
      - If `false` → `emit(AuthState.unauthenticated());`

- **File**: `lib/core/auth/auth_repository.dart`
  - `Future<bool> hasActiveSession()`:
    - Calls `SecureStorageService.getAccessToken()`.
    - Returns `true` if token is non-empty.

### 2. Route guard / protected routes

- **File**: `lib/core/navigation/app_router.dart`
  - `_publicRoutes = {splash, login}`.
  - `generateRoute(RouteSettings settings)`:
    - `requiresAuth = !_publicRoutes.contains(settings.name);`
    - If `requiresAuth`:
      - Fetches `final authCubit = di.sl<AuthCubit>();`
      - If `!authCubit.state.isAuthenticated`:
        - Returns `MaterialPageRoute` to `LoginScreen`:
          - `initialMessage: authCubit.state.message`.
    - So **all other routes** (`/`, `/menu`, `/checkout`, `/orders`, etc.) require authenticated state.

### 3. Splash & login screens

#### Splash

- **File**: `lib/features/auth/presentation/screens/auth_splash_screen.dart`
  - Simple spinner/text: “Securing your session...”.
  - No logic; just a waiting screen while `AuthCubit` resolves to authenticated/unauthenticated.

#### Login

- **File**: `lib/features/auth/presentation/screens/login_screen.dart`

- **Validation & submission**
  - Uses `Form` with email/password fields.
  - On **Sign In** button:
    - `_submit(AuthCubit cubit)`:
      - Validates `_formKey`.
      - `email = InputSanitizer.sanitizeEmail(...)`.
      - `password = _passwordController.text`.
      - Calls `await cubit.login(email: email, password: password);`

- **Listening to auth state**
  - `BlocConsumer<AuthCubit, AuthState>`:
    - `listener`:
      - If `state.errorMessage != null` → shows SnackBar with the error.
      - Else if `state.message != null && state.status != AuthStatus.authenticated`
        → shows info SnackBar.
    - `builder`:
      - Disables button and shows progress indicator when `state.isLoading == true`.

### 4. Login repository & API call

- **File**: `lib/core/auth/auth_cubit.dart`
  - `login(email, password)`:
    - `emit(state.copyWith(isLoading: true, errorMessage: null));`
    - Calls `_authRepository.login(email: email, password: password);`
    - On success → `emit(AuthState.authenticated());`
    - On `AuthException` → `emit` unauthenticated with `errorMessage`.

- **File**: `lib/core/auth/auth_repository.dart`

#### 4.1 API call

- `Future<void> login({required String email, required String password})`
  - Calls `_remoteDataSource.login(email: email, password: password);`

- **File**: `lib/core/auth/data/datasources/auth_remote_datasource.dart`
  - `AuthRemoteDataSourceImpl.login(...)`:
    - Builds `FormData`:
      - `email`
      - `password`
    - Endpoint path: `auth/login` (relative).
      - Base URL from `Dio` options is configured elsewhere (e.g. `https://v3.ozfoodz.com.au/api/pos/`).
    - Sends:
      - `POST auth/login`
      - Content-Type: `multipart/form-data`
      - Headers: `Accept: application/json`
    - Parses response body into `LoginResponseModel`.

#### 4.2 Response model

- **File**: `lib/core/auth/data/models/login_response_model.dart`
  - `LoginResponseModel`:
    - Fields:
      - `bool success`
      - `String? message`
      - `LoginDataModel? data`
  - `LoginDataModel` (the important `data` fields):
    - `id` (int)
    - `name` (String)
    - `email` (String)
    - `role` (String)
    - `vendorUuid`
    - `vendorName`
    - `branchUuid`
    - `branchName`
    - `token` (String – bearer token)

#### 4.3 Repository logic & storage

- After getting `response`:
  - If `!response.success || response.data == null`:
    - Throws `AuthException(response.message ?? 'Login failed. Please try again.')`.
  - If `response.data!.token.isEmpty`:
    - Throws `AuthException('Authentication response missing token')`.

- On success (with non-empty token):
  - Saves token to **secure storage**:
    - `SecureStorageService.saveAccessToken(data.token);`
  - Duplicates token + user info into **SharedPreferences** using keys in `AppConstants`:
    - `authUserIdKey` (`int`)
    - `authUserNameKey`
    - `authUserEmailKey`
    - `authUserRoleKey`
    - `authVendorUuidKey`
    - `authVendorNameKey`
    - `authBranchUuidKey`
    - `authBranchNameKey`
    - `authTokenPrefKey` (token copy)
  - Stores a **JSON-encoded user payload** under `userKey`:
    - Map: `{ id, name, email, role, vendor_uuid, vendor_name, branch_uuid, branch_name }`

---

## API hits

### 1. Login

- **File**: `lib/core/auth/data/datasources/auth_remote_datasource.dart`
- **Endpoint**
  - Relative: `auth/login`
  - Effective: `${dio.options.baseUrl}auth/login`  
    (base URL configured in `ApiClient` / DI, e.g. `https://v3.ozfoodz.com.au/api/pos/`)
- **Method**: `POST`
- **Request payload (multipart/form-data)**
  - `email` (String)
  - `password` (String)
- **Headers**
  - `Accept: application/json`
  - `Content-Type: multipart/form-data`
- **Response (used fields)**
  - `success` (bool)
  - `message` (String?) – used only for error messaging.
  - `data` (object):
    - `id`
    - `name`
    - `email`
    - `role`
    - `vendor_uuid`
    - `vendor_name`
    - `branch_uuid`
    - `branch_name`
    - `token` (access token used as Bearer)
- **Where response data is saved**
  - Token:
    - `SecureStorageService.saveAccessToken(data.token)` → encrypted storage.
  - User/session metadata:
    - `SharedPreferences` under multiple keys (see above).
  - Combined user object:
    - `SharedPreferences.setString(AppConstants.userKey, jsonEncode(userPayload));`
- **Where saved data is reused**
  - `AuthRepository.hasActiveSession()`:
    - Reads access token from `SecureStorageService` to determine if the user is signed in.
  - `ApiClient`:
    - (Not shown in full here, but typical pattern) attaches token from `SecureStorageService` as `Authorization: Bearer <token>` on outgoing API requests and handles token refresh logic.

### 2. Logout

- **File**: `lib/core/auth/data/datasources/auth_remote_datasource.dart`
- **Endpoint**
  - Relative: `auth/logout`
  - Effective: `${dio.options.baseUrl}auth/logout`
- **Method**: `POST`
- **Headers**
  - `Accept: application/json`
  - The `Dio` instance used by `AuthRemoteDataSourceImpl` is also used by `ApiClient`, which typically attaches:
    - `Authorization: Bearer <token>` from secure storage.
- **Request payload**
  - None (body empty).
- **Response (used fields)**
  - Status code for logging; response body is not used logically.
- **Where response result is used**
  - `AuthRepository.logout()` logs success/failure in debug, but:
    - Always clears local tokens and user data regardless of API outcome.

---

## Data saved / state updated

### Token & user data

- **Access token**
  - `SecureStorageService.saveAccessToken(token)`  
  - Key: `AppConstants.tokenKey`
  - Used by:
    - `AuthRepository.hasActiveSession()`.
    - `ApiClient` (for Authorization header and token refresh).

- **User profile & context**
  - `SharedPreferences` keys (`AppConstants.*`):
    - `authUserIdKey`
    - `authUserNameKey`
    - `authUserEmailKey`
    - `authUserRoleKey`
    - `authVendorUuidKey`
    - `authVendorNameKey`
    - `authBranchUuidKey`
    - `authBranchNameKey`
    - `authTokenPrefKey`
    - `userKey` (JSON-encoded user map)
  - Usage in current codebase:
    - These values are stored for later; the snippets provided do not show heavy reuse yet beyond potential analytics/printing/context.
    - The important part for **auth** itself is the access token in secure storage.

### Auth state

- `AuthCubit` maintains `AuthState`:
  - `status` (unknown, unauthenticated, authenticated, locked)
  - `isLoading`
  - `message` (info messages like “Session expired”)
  - `errorMessage` (login failure text)

- `main.dart` reacts to `AuthState`:
  - Drives navigation between login/dashboard and controls `SessionTimeoutManager`.

### Session timeout

- **File**: `lib/core/auth/session_timeout_manager.dart`
  - Holds `_timeout` (default 15 minutes).
  - `configure({required AuthCubit authCubit, Duration? timeout})` called from `main.dart` with the DI-provided `AuthCubit`.
  - `start()`:
    - Sets `_enabled = true`.
    - Calls `resetTimer()`.
  - `resetTimer()`:
    - Cancels any existing timer.
    - Starts a new `Timer(_timeout, ...)` that calls:
      - `authCubit.lockSession(reason: 'Session locked due to inactivity')`.
  - `stop()`:
    - Cancels timer and disables manager.

- **Effect**:
  - When timeout fires:
    - `AuthCubit.lockSession()` emits `AuthState.locked(...)`.
    - `main.dart` listener:
      - Treats `AuthStatus.locked` like unauthenticated:
        - Stops timeout manager.
        - Navigates to `/login`.

---

## Files involved

- **Core auth**
  - `lib/core/auth/auth_cubit.dart`
  - `lib/core/auth/auth_state.dart`
  - `lib/core/auth/auth_repository.dart`
  - `lib/core/auth/data/datasources/auth_remote_datasource.dart`
  - `lib/core/auth/data/models/login_response_model.dart`
  - `lib/core/auth/session_timeout_manager.dart`
  - `lib/core/storage/secure_storage_service.dart`
  - `lib/core/di/modules/core_module.dart`

- **UI / routing**
  - `lib/main.dart`
  - `lib/core/navigation/app_router.dart`
  - `lib/features/auth/presentation/screens/auth_splash_screen.dart`
  - `lib/features/auth/presentation/screens/login_screen.dart`
  - `lib/features/dashboard/presentation/screens/dashboard_screen.dart` (logout button)

- **Network / 401 handling**
  - `lib/core/network/api_client.dart` (`_handleUnauthorized`)

---

## Conditions / branches

- **Session check**
  - Branch: `hasActiveSession()`:
    - `true` → authenticated state → dashboard.
    - `false` → unauthenticated state → login.

- **Route guard**
  - If `settings.name` not in `_publicRoutes`:
    - If `AuthCubit.state.isAuthenticated == false`:
      - Route **always** replaced by `LoginScreen`.

- **Login result**
  - `success == true` + `data != null` + `token non-empty`:
    - Save data → `AuthState.authenticated`.
  - Otherwise:
    - Throw `AuthException` → `AuthState` with `errorMessage`.

- **Logout result**
  - API call success/failure is logged but **local session is always cleared**.

- **401 unauthorized**
  - If token refresh mechanism (in `ApiClient`, not fully shown above) fails:
    - `_handleUnauthorized()`:
      - Clears tokens/user.
      - Calls `AuthCubit.handleUnauthorized(reason: 'Session expired...')`.
      - Navigates to `/login` with message.

- **Session timeout**
  - After 15 minutes of inactivity (or configured timeout):
    - `SessionTimeoutManager` fires → `AuthCubit.lockSession()`.
    - Treated like unauthenticated (redirect to login).

---

## Error cases

- **Incorrect email/password**
  - API returns 401.
  - `AuthRepository._mapDioError` maps 401 to:
    - `'Invalid email or password'`.
  - `AuthCubit.login` emits unauthenticated state with this `errorMessage`.
  - `LoginScreen` shows it via SnackBar.

- **Network timeouts**
  - If `DioException.type` is connection/receive/send timeout:
    - Error mapped to:
      - `'Unable to reach the server. Check your connection.'`

- **Unexpected error**
  - Any other `DioException` with `response.data['message']`:
    - That message is used.
  - If nothing matches:
    - `'Authentication failed. Please try again.'`

- **Missing token in successful response**
  - If `data.token` is empty:
    - Throw `AuthException('Authentication response missing token')`.

- **Null response body**
  - If `response.data == null` on login:
    - Throws `Exception('Login response body is null')` (caught and wrapped in `AuthException`).

- **Logout API failure**
  - Any exceptions during `AuthRemoteDataSource.logout()`:
    - Logged, but local session is still cleared.

- **Unauthorized 401 during other API calls**
  - Handled via `ApiClient._handleUnauthorized()` as described above.

---

## Legacy / unclear areas

- **Refresh token handling**
  - `SecureStorageService` supports refresh tokens (`saveRefreshToken`, `getRefreshToken`, `saveTokens`, etc.).
  - However:
    - `AuthRepository.login()` **only saves** `accessToken` (no refresh token).
    - There is no refresh token field in `LoginDataModel`.
    - `Not found in current codebase`: real refresh-token usage.

- **User role / permissions**
  - `LoginDataModel.role` is stored to `SharedPreferences` under `authUserRoleKey`.
  - There is **no role-based routing/authorization** found:
    - `Not found in current codebase`: role checks / per-feature permissions.

- **Profile fetch / update**
  - No separate “profile” API (e.g., `auth/me`) is implemented:
    - All user info comes from the login response and is cached.
    - `Not found in current codebase`: profile fetch / update flow.

- **Register / Forgot password**
  - UI:
    - `LoginScreen` has a “Forgot password?” link that only shows:
      - `'Contact your administrator to reset credentials.'`
  - No registration or forgot-password APIs:
    - `Not found in current codebase`: register / forgot password endpoints.

---

## Quick summary

- Authentication is handled via **email/password login** against `auth/login` and a **logout** call to `auth/logout`.
- Tokens are stored in **secure storage**; user context (id, name, email, role, vendor/branch) is duplicated into **SharedPreferences**.
- `AuthCubit` manages auth state (`unknown`, `unauthenticated`, `authenticated`, `locked`) and is the single source of truth used by:
  - Route guard in `AppRouter`.
  - Global listener in `main.dart` for navigation.
- All routes except `/splash` and `/login` are **protected** and will redirect to login when there is no active authenticated session.
- `ApiClient` intercepts 401 responses, clears auth, notifies `AuthCubit`, and redirects to login with a “Session expired” message.
- There is support infrastructure for refresh tokens and roles, but **no actual refresh-token or role-based authorization logic is implemented** in the current codebase.  
  Where a feature is not implemented, we explicitly mark it as: `Not found in current codebase`.

