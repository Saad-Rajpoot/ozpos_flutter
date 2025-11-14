import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Secure storage service for sensitive data like authentication tokens
///
/// **SECURITY**: Uses platform-specific secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences (uses Android Keystore)
/// - Web: LocalStorage (encrypted with AES)
/// - Linux: LibSecret
/// - macOS: Keychain
/// - Windows: DPAPI
///
/// This service should be used for:
/// - Authentication tokens (access & refresh)
/// - API keys
/// - Sensitive user credentials
///
/// Do NOT use for non-sensitive data (use SharedPreferences instead).
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    // Android-specific options
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // Use hardware-backed storage if available (Android 6.0+)
      // Falls back to software keystore if hardware not available
    ),
    // iOS-specific options
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      // Requires device unlock to access
    ),
    // Linux-specific options
    lOptions: LinuxOptions(),
    // macOS-specific options
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    // Windows-specific options
    wOptions: WindowsOptions(),
  );

  /// Store an access token securely
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(
        key: AppConstants.tokenKey,
        value: token,
      );
      if (kDebugMode) {
        debugPrint('✅ Access token saved securely');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to save access token: $e');
      }
      rethrow;
    }
  }

  /// Retrieve the access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: AppConstants.tokenKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to read access token: $e');
      }
      return null;
    }
  }

  /// Store a refresh token securely
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(
        key: AppConstants.refreshTokenKey,
        value: token,
      );
      if (kDebugMode) {
        debugPrint('✅ Refresh token saved securely');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to save refresh token: $e');
      }
      rethrow;
    }
  }

  /// Retrieve the refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to read refresh token: $e');
      }
      return null;
    }
  }

  /// Store both tokens at once
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        saveAccessToken(accessToken),
        saveRefreshToken(refreshToken),
      ]);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to save tokens: $e');
      }
      rethrow;
    }
  }

  /// Delete access token
  Future<void> deleteAccessToken() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
      if (kDebugMode) {
        debugPrint('✅ Access token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to delete access token: $e');
      }
    }
  }

  /// Delete refresh token
  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: AppConstants.refreshTokenKey);
      if (kDebugMode) {
        debugPrint('✅ Refresh token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to delete refresh token: $e');
      }
    }
  }

  /// Delete all authentication tokens
  Future<void> deleteAllTokens() async {
    try {
      await Future.wait([
        deleteAccessToken(),
        deleteRefreshToken(),
      ]);
      if (kDebugMode) {
        debugPrint('✅ All tokens deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to delete tokens: $e');
      }
    }
  }

  /// Check if access token exists
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if refresh token exists
  Future<bool> hasRefreshToken() async {
    final token = await getRefreshToken();
    return token != null && token.isNotEmpty;
  }

  /// Store a generic secure value
  /// Use this for other sensitive data like API keys
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to write secure value for key $key: $e');
      }
      rethrow;
    }
  }

  /// Read a generic secure value
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to read secure value for key $key: $e');
      }
      return null;
    }
  }

  /// Delete a generic secure value
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to delete secure value for key $key: $e');
      }
    }
  }

  /// Delete all secure values (use with caution)
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      if (kDebugMode) {
        debugPrint('✅ All secure storage cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to clear secure storage: $e');
      }
    }
  }
}
