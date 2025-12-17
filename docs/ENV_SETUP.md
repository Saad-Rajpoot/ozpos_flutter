# Environment Configuration

## Overview

This project uses compile-time environment variables for sensitive configuration like API keys and DSNs. These are set using Flutter's `--dart-define` flag.

## Required Environment Variables

### SENTRY_DSN
Your Sentry Data Source Name for error tracking.

```bash
--dart-define=SENTRY_DSN=https://your_sentry_dsn_here
```

### API_BASE_URL (Optional)
Override the default API base URL.

```bash
--dart-define=API_BASE_URL=https://your-api.com/v1
```

### ENVIRONMENT (Optional)
Set the environment (debug, staging, production). Defaults to 'debug'.

```bash
--dart-define=ENVIRONMENT=production
```

## Usage

### Running the app

```bash
# Development with Sentry
flutter run --dart-define=SENTRY_DSN=your_dsn_here

# Production build
flutter build apk --dart-define=ENVIRONMENT=production --dart-define=SENTRY_DSN=your_dsn_here --dart-define=API_BASE_URL=https://api.ozpos.com/v1
```

### VS Code Launch Configuration

Add to `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "ozpos_flutter (Development)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=SENTRY_DSN=your_sentry_dsn_here",
        "--dart-define=ENVIRONMENT=debug"
      ]
    },
    {
      "name": "ozpos_flutter (Production)",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=SENTRY_DSN=your_sentry_dsn_here",
        "--dart-define=ENVIRONMENT=production",
        "--dart-define=API_BASE_URL=https://api.ozpos.com/v1"
      ]
    }
  ]
}
```

### Android Studio / IntelliJ

1. Go to Run > Edit Configurations
2. Under "Additional run args", add:
   ```
   --dart-define=SENTRY_DSN=your_sentry_dsn_here
   ```

## Security Notes

- **Never commit sensitive values to version control**
- Use CI/CD environment variables for production builds
- The default value for `SENTRY_DSN` is empty string - you must explicitly configure it
- Consider using a secrets manager for production deployments

## CI/CD Example

### GitHub Actions

```yaml
- name: Build APK
  run: |
    flutter build apk \
      --dart-define=SENTRY_DSN=${{ secrets.SENTRY_DSN }} \
      --dart-define=ENVIRONMENT=production \
      --dart-define=API_BASE_URL=${{ secrets.API_BASE_URL }}
```

### GitLab CI

```yaml
build:
  script:
    - flutter build apk
        --dart-define=SENTRY_DSN=${SENTRY_DSN}
        --dart-define=ENVIRONMENT=production
        --dart-define=API_BASE_URL=${API_BASE_URL}
```

## Default Values

If environment variables are not provided:

- `SENTRY_DSN`: Empty string (Sentry will be disabled)
- `API_BASE_URL`: Uses environment-based defaults:
  - Debug: `http://localhost:8000/api/v1`
  - Staging: `https://staging-api.ozpos.com/v1`
  - Production: `https://api.ozpos.com/v1`
- `ENVIRONMENT`: `debug`

