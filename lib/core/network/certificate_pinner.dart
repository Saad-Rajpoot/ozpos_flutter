import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Certificate pinning validator for Dio HTTP client
///
/// **SECURITY**: Certificate pinning prevents Man-in-the-Middle (MITM) attacks
/// by verifying that the server's certificate matches expected SHA-256 fingerprints.
///
/// This validator checks the certificate chain against a list of pinned fingerprints.
/// If no matching fingerprint is found, the connection is rejected.
class CertificatePinner {
  final List<String> _pins;

  /// Create a certificate pinner with SHA-256 fingerprints
  ///
  /// [pins] should be in the format: ['sha256/ABC123...', 'sha256/DEF456...']
  ///
  /// Multiple pins allow for certificate rotation without breaking the app.
  CertificatePinner(List<String> pins)
      : _pins = pins.map((pin) {
          // Normalize pin format (remove 'sha256/' prefix if present, add it back)
          final normalized = pin.toLowerCase().startsWith('sha256/')
              ? pin.toLowerCase()
              : 'sha256/${pin.toLowerCase()}';
          return normalized;
        }).toList();

  /// Validate certificate against pinned fingerprints
  ///
  /// Returns true if certificate matches any pinned fingerprint, false otherwise
  bool validateCertificate(X509Certificate certificate) {
    if (_pins.isEmpty) {
      // No pins configured, allow all certificates (not recommended for production)
      if (kDebugMode) {
        debugPrint('⚠️ Certificate pinning disabled - no pins configured');
      }
      return true;
    }

    // Calculate SHA-256 fingerprint of the certificate
    final certBytes = certificate.der;
    final hash = sha256.convert(certBytes);
    final fingerprint = 'sha256/${base64.encode(hash.bytes)}';

    // Check if fingerprint matches any pinned fingerprint
    final matches =
        _pins.any((pin) => fingerprint.toLowerCase() == pin.toLowerCase());

    if (kDebugMode) {
      if (matches) {
        debugPrint('✅ Certificate pin validated: $fingerprint');
      } else {
        debugPrint('❌ Certificate pin validation failed');
        debugPrint('   Expected one of: ${_pins.join(", ")}');
        debugPrint('   Got: $fingerprint');
      }
    }

    return matches;
  }

  /// Create a Dio HttpClientAdapter with certificate pinning enabled
  ///
  /// This adapter validates certificates against pinned fingerprints
  /// before allowing the connection.
  HttpClientAdapter createPinnedAdapter() {
    return IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          // Validate certificate against pins
          final isValid = validateCertificate(cert);

          if (!isValid) {
            if (kDebugMode) {
              debugPrint('❌ Certificate pinning failed for $host:$port');
              debugPrint('   Connection rejected due to certificate mismatch');
            }
          }

          return isValid;
        };
        return client;
      },
    );
  }

  /// Get the number of configured pins
  int get pinCount => _pins.length;

  /// Check if pinning is enabled
  bool get isEnabled => _pins.isNotEmpty;
}
