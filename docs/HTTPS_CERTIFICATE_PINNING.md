# HTTPS and Certificate Pinning Configuration

This document describes the HTTPS enforcement and certificate pinning implementation for secure network communication.

## Overview

The application enforces HTTPS in production and supports certificate pinning to prevent Man-in-the-Middle (MITM) attacks. This provides defense-in-depth security for network communications.

## HTTPS Enforcement

### Production Environment

- **HTTPS is mandatory** in production builds
- HTTP URLs are rejected at runtime
- Base URL validation ensures HTTPS protocol

### Development Environment

- HTTP is allowed for local development (e.g., `http://localhost:8000`)
- HTTPS is still recommended even in development

### Configuration

The base URL is configured via `AppConfig` and can be overridden:

```bash
# Production build with custom API URL
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com/v1
```

**Security**: If a non-HTTPS URL is provided in production, the app will throw an error at startup.

## Certificate Pinning

### What is Certificate Pinning?

Certificate pinning is a security mechanism that ensures the app only accepts connections from servers with specific SSL/TLS certificates. This prevents:

- **MITM Attacks**: Even if an attacker has a valid CA-signed certificate, the connection will be rejected if it doesn't match the pinned certificate
- **Compromised CA**: Protects against attacks using certificates from compromised Certificate Authorities
- **Proxy Interception**: Prevents corporate proxies or security tools from intercepting traffic

### How It Works

1. The app stores SHA-256 fingerprints of trusted server certificates
2. When connecting to the server, the app validates the certificate against these fingerprints
3. If the certificate doesn't match any pinned fingerprint, the connection is rejected

### Getting Certificate Fingerprints

To enable certificate pinning, you need to extract the SHA-256 fingerprint of your server's certificate:

#### Using OpenSSL (Linux/macOS):

```bash
openssl s_client -servername api.ozpos.com -connect api.ozpos.com:443 < /dev/null 2>/dev/null | \
  openssl x509 -fingerprint -sha256 -noout -in /dev/stdin
```

#### Using OpenSSL (Windows PowerShell):

```powershell
$cert = [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$request = [System.Net.HttpWebRequest]::Create("https://api.ozpos.com")
$request.GetResponse() | Out-Null
$cert = $request.ServicePoint.Certificate
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$hash = $sha256.ComputeHash($cert.GetRawCertData())
$fingerprint = "sha256/" + [System.Convert]::ToBase64String($hash)
Write-Host $fingerprint
```

#### Using Online Tools:

You can also use online SSL checker tools to get certificate fingerprints, but verify the fingerprint matches your actual server certificate.

### Enabling Certificate Pinning

Certificate pinning is configured via build-time flags:

```bash
flutter build apk --release \
  --dart-define=CERT_PIN_1=sha256/ABC123... \
  --dart-define=CERT_PIN_2=sha256/DEF456... \
  --dart-define=CERT_PIN_3=sha256/GHI789...
```

**Multiple Pins**: You can provide up to 3 certificate pins. This allows for:
- **Certificate Rotation**: Update server certificates without breaking the app
- **Backup Certificates**: Support multiple certificates (e.g., primary and backup)
- **Certificate Chain**: Pin multiple certificates in the chain

### Certificate Pin Format

Pins must be in the format: `sha256/BASE64_ENCODED_FINGERPRINT`

Example:
```
sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
```

The `sha256/` prefix is optional - it will be added automatically if missing.

### Verification

When certificate pinning is enabled, you'll see in debug logs:

```
✅ Certificate pinning enabled with 2 pin(s)
✅ Certificate pin validated: sha256/ABC123...
```

If pinning fails:

```
❌ Certificate pin validation failed
   Expected one of: sha256/ABC123..., sha256/DEF456...
   Got: sha256/XYZ789...
❌ Certificate pinning failed for api.ozpos.com:443
   Connection rejected due to certificate mismatch
```

## Configuration Examples

### Development (No Pinning)

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

### Production (HTTPS Only)

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.ozpos.com/v1
```

### Production (HTTPS + Certificate Pinning)

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.ozpos.com/v1 \
  --dart-define=CERT_PIN_1=sha256/ABC123... \
  --dart-define=CERT_PIN_2=sha256/DEF456...
```

### CI/CD Configuration

For CI/CD pipelines, store certificate pins as secrets:

```yaml
# GitHub Actions example
env:
  CERT_PIN_1: ${{ secrets.CERT_PIN_1 }}
  CERT_PIN_2: ${{ secrets.CERT_PIN_2 }}

flutter build apk --release \
  --dart-define=CERT_PIN_1=$CERT_PIN_1 \
  --dart-define=CERT_PIN_2=$CERT_PIN_2
```

## Certificate Rotation

When rotating server certificates:

1. **Before Rotation**: Add the new certificate pin to the app
2. **Deploy App**: Release app update with both old and new pins
3. **Rotate Certificate**: Update server certificate
4. **After Rotation**: Remove old certificate pin in next app update

This ensures zero downtime during certificate rotation.

## Troubleshooting

### Connection Fails After Enabling Pinning

**Symptom**: App cannot connect to server after enabling certificate pinning

**Causes**:
- Incorrect certificate fingerprint
- Certificate has been rotated/updated
- Using wrong certificate (e.g., intermediate vs leaf)

**Solution**:
1. Verify certificate fingerprint matches server
2. Check if certificate was recently updated
3. Ensure you're pinning the correct certificate (usually the leaf certificate)

### App Works in Development but Fails in Production

**Symptom**: App works fine in debug but fails in release builds

**Causes**:
- Certificate pinning only enabled in release builds
- Different certificates for dev/staging/production

**Solution**:
1. Test certificate pinning in debug builds first
2. Verify production certificate fingerprints
3. Ensure all environments use the same certificate or pin all certificates

### Certificate Pinning Disabled Warning

**Symptom**: See warning "Certificate pinning is disabled in production"

**Solution**:
- This is a warning, not an error
- App will still work but without certificate pinning protection
- Enable certificate pinning for enhanced security

## Security Best Practices

### ✅ DO:
- Always use HTTPS in production
- Enable certificate pinning for production builds
- Store certificate pins as secrets in CI/CD
- Test certificate pinning before production deployment
- Use multiple pins for certificate rotation support
- Keep certificate pins up to date

### ❌ DON'T:
- Use HTTP in production
- Commit certificate pins to version control
- Pin certificates without testing
- Use only one pin (prevents certificate rotation)
- Disable certificate validation
- Ignore certificate pinning failures

## Implementation Details

### AppConfig

The `AppConfig` class provides:
- `apiBaseUrl`: Base URL with HTTPS enforcement
- `enforceHttps`: Whether HTTPS is required
- `certificatePins`: List of pinned certificate fingerprints
- `isCertificatePinningEnabled`: Whether pinning is active

### ApiClient

The `ApiClient` class:
- Validates base URL on initialization
- Configures certificate pinning if enabled
- Applies pinning to all HTTP requests
- Includes pinning in token refresh requests

### CertificatePinner

The `CertificatePinner` class:
- Validates certificates against pinned fingerprints
- Creates Dio HttpClientAdapter with pinning
- Provides detailed logging for debugging

## Additional Resources

- [OWASP Certificate Pinning Guide](https://owasp.org/www-community/controls/Certificate_and_Public_Key_Pinning)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [Dio HTTP Client](https://pub.dev/packages/dio)
- [SSL Labs SSL Test](https://www.ssllabs.com/ssltest/) - Test your server's SSL configuration

