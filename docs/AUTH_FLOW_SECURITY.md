# Authentication Flow Security

## Overview

The OZPOS Flutter app now includes a hardened authentication flow designed to prevent unauthorized access, enforce HTTPS-only transport, and handle idle sessions appropriately.

Key improvements:

- Dedicated login route (`/login`) with secure credential validation
- Splash/auth-gate route that checks persisted tokens before exposing the dashboard
- Centralized `AuthCubit` + `AuthRepository` handling sessions, tokens, and logout
- Certificate pinning support during login and refresh endpoints
- Idle-timeout manager that locks the session after 15 minutes of inactivity
- Navigation guard that redirects unauthenticated users to the login screen
- `_handleUnauthorized` now clears tokens and triggers auth logout state instead of silently returning to the dashboard

## Architecture

```
LoginScreen -> AuthCubit (Bloc) -> AuthRepository -> SecureStorageService
                                           |
                                           -> SessionTimeoutManager
```

### AuthCubit (`lib/core/auth/auth_cubit.dart`)

- Loads existing session on startup
- Provides `login`, `logout`, `lockSession`, `handleUnauthorized`
- Emits `AuthState` with statuses: `unknown`, `unauthenticated`, `authenticated`, `locked`
- Coordinated with `SessionTimeoutManager` for idle lockouts

### AuthRepository (`lib/core/auth/auth_repository.dart`)

- Uses `Dio` to call `POST /auth/login`
- Respects certificate pinning if configured
- Stores access/refresh tokens via `SecureStorageService`
- Persist user profile payload into `SharedPreferences`

### SessionTimeoutManager (`lib/core/auth/session_timeout_manager.dart`)

- 15-minute default timeout (configurable)
- Reset on every pointer event (`UserInteractionListener`)
- Locks the session via `AuthCubit.lockSession` when idle timer fires

## Navigation Flow

1. App launches → `AppRouter.splash`
2. `AuthCubit` checks secure storage
3. If tokens exist → `AuthState.authenticated` → navigate to dashboard
4. If no tokens → `AuthState.unauthenticated` → stay on login route
5. Any 401 from API → `_handleUnauthorized` clears storage + calls `AuthCubit.handleUnauthorized` → login screen with reason message
6. Idle timeout → `SessionTimeoutManager` locks → login screen (must re-auth)

## Usage

### Running in development

```
flutter run --dart-define=APP_ENV=development --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

### Running in production

```
flutter build apk --release \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://api.ozpos.com/v1 \
  --dart-define=SENTRY_DSN=... \
  --dart-define=CERT_PIN_1=sha256/...
```

## Future Enhancements

- Integrate platform biometrics (LocalAuth) for step-up auth
- Support refresh-token rotation + device binding
- Add per-route role/permission metadata
- Implement backend-driven session revocation

