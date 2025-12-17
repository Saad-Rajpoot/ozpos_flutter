import 'package:flutter/foundation.dart';

/// Comprehensive input validation utilities
///
/// **SECURITY**: These validators prevent injection attacks, enforce data integrity,
/// and sanitize user input before sending to the backend.
class InputValidators {
  InputValidators._();

  /// Validates required field (non-empty)
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let required validator handle empty values
    }
    if (value.trim().length < min) {
      return '${fieldName ?? 'Field'} must be at least $min characters';
    }
    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let required validator handle empty values
    }
    if (value.length > max) {
      return '${fieldName ?? 'Field'} must not exceed $max characters';
    }
    return null;
  }

  /// Validates length range
  static String? lengthRange(
    String? value,
    int min,
    int max, {
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let required validator handle empty values
    }
    final trimmed = value.trim();
    if (trimmed.length < min || trimmed.length > max) {
      return '${fieldName ?? 'Field'} must be between $min and $max characters';
    }
    return null;
  }

  /// Validates email format
  static String? email(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let required validator handle empty values
    }

    // RFC 5322 compliant email regex (simplified but secure)
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    // Additional length check (RFC 5321 limit)
    if (value.length > 254) {
      return 'Email address is too long';
    }

    return null;
  }

  /// Validates phone number format
  /// Supports international formats with optional + prefix
  static String? phone(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let required validator handle empty values
    }

    // Remove common formatting characters for validation
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // International phone regex: + followed by 7-15 digits, or 10-15 digits without +
    final phoneRegex = RegExp(r'^(\+?[1-9]\d{6,14}|\d{10,15})$');

    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates numeric input
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let required validator handle empty values
    }
    if (double.tryParse(value.trim()) == null) {
      return '${fieldName ?? 'Field'} must be a number';
    }
    return null;
  }

  /// Validates integer input
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let required validator handle empty values
    }
    if (int.tryParse(value.trim()) == null) {
      return '${fieldName ?? 'Field'} must be a whole number';
    }
    return null;
  }

  /// Validates positive number
  static String? positiveNumber(String? value, {String? fieldName}) {
    final numericError = numeric(value, fieldName: fieldName);
    if (numericError != null) return numericError;

    if (value != null) {
      final num = double.tryParse(value.trim());
      if (num != null && num <= 0) {
        return '${fieldName ?? 'Field'} must be greater than 0';
      }
    }
    return null;
  }

  /// Validates number range
  static String? numberRange(
    String? value,
    double min,
    double max, {
    String? fieldName,
  }) {
    final numericError = numeric(value, fieldName: fieldName);
    if (numericError != null) return numericError;

    if (value != null) {
      final num = double.tryParse(value.trim());
      if (num != null && (num < min || num > max)) {
        return '${fieldName ?? 'Field'} must be between $min and $max';
      }
    }
    return null;
  }

  /// Validates alphanumeric characters only
  static String? alphanumeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let required validator handle empty values
    }
    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!alphanumericRegex.hasMatch(value.trim())) {
      return '${fieldName ?? 'Field'} can only contain letters and numbers';
    }
    return null;
  }

  /// Validates alphabetic characters only
  static String? alphabetic(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let required validator handle empty values
    }
    final alphabeticRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!alphabeticRegex.hasMatch(value.trim())) {
      return '${fieldName ?? 'Field'} can only contain letters';
    }
    return null;
  }

  /// Validates username format (alphanumeric, underscore, hyphen, 3-30 chars)
  static String? username(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let required validator handle empty values
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_-]{3,30}$');
    if (!usernameRegex.hasMatch(value.trim())) {
      return '${fieldName ?? 'Username'} must be 3-30 characters and contain only letters, numbers, underscores, or hyphens';
    }
    return null;
  }

  /// Validates password strength
  /// Requires: 8+ chars, at least one letter and one number
  static String? password(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let required validator handle empty values
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validates URL format
  static String? url(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let required validator handle empty values
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validates that input doesn't contain dangerous patterns
  /// Checks for SQL injection, XSS, and command injection patterns
  static String? noDangerousPatterns(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // SQL injection patterns
    final sqlPatterns = <RegExp>[
      RegExp(
          r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|EXECUTE)\b)',
          caseSensitive: false),
      RegExp(r'(\b(UNION|OR|AND)\s+\d+\s*=\s*\d+)', caseSensitive: false),
      RegExp(r"('|;|--|/\*|\*/)", caseSensitive: false),
    ];

    // XSS patterns
    final xssPatterns = <RegExp>[
      RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false), // onclick, onerror, etc.
      RegExp(r'<iframe[^>]*>', caseSensitive: false),
    ];

    // Command injection patterns
    final commandPatterns = <RegExp>[
      RegExp(r'[;&|`\$(){}]', caseSensitive: false),
      RegExp(r'\b(cat|ls|pwd|whoami|id|uname)\b', caseSensitive: false),
    ];

    for (final pattern in [
      ...sqlPatterns,
      ...xssPatterns,
      ...commandPatterns
    ]) {
      if (pattern.hasMatch(value)) {
        if (kDebugMode) {
          debugPrint(
              '⚠️ Dangerous pattern detected in input: ${pattern.pattern}');
        }
        return 'Input contains invalid characters or patterns';
      }
    }

    return null;
  }

  /// Validates that input only contains safe characters
  /// Allows letters, numbers, spaces, and common punctuation
  static String? safeCharactersOnly(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // Allow letters, numbers, spaces, and safe punctuation
    final safeRegex = RegExp(r'^[a-zA-Z0-9\s.,!?\-_()@#\$%&*+=:;]+$');

    if (!safeRegex.hasMatch(value)) {
      return '${fieldName ?? 'Field'} contains invalid characters';
    }

    return null;
  }

  /// Combines multiple validators
  /// Returns first error found, or null if all validations pass
  static String? combine(
      List<String? Function(String?)> validators, String? value) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Validates driver name (letters, spaces, hyphens, 2-50 chars)
  static String? driverName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Driver name is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return 'Driver name must be at least 2 characters';
    }

    if (trimmed.length > 50) {
      return 'Driver name must not exceed 50 characters';
    }

    // Allow letters, spaces, hyphens, apostrophes
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Driver name can only contain letters, spaces, hyphens, and apostrophes';
    }

    // Check for dangerous patterns
    final dangerousError = noDangerousPatterns(trimmed);
    if (dangerousError != null) {
      return dangerousError;
    }

    return null;
  }

  /// Validates driver phone number
  static String? driverPhone(String? value) {
    return combine([
      (v) => required(v, fieldName: 'Phone number'),
      (v) => phone(v, fieldName: 'Phone number'),
    ], value);
  }

  /// Validates driver email
  static String? driverEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }
    return email(value, fieldName: 'Email');
  }

  /// Validates driver username
  static String? driverUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Username is optional (auto-generated)
    }
    return username(value, fieldName: 'Username');
  }
}
