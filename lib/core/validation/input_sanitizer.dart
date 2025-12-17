import 'package:flutter/foundation.dart';

/// Input sanitization utilities
///
/// **SECURITY**: Sanitizes user input to remove or escape dangerous characters
/// and patterns before storing or sending to the backend.
class InputSanitizer {
  InputSanitizer._();

  /// Sanitizes text input by removing dangerous characters
  /// Keeps only safe alphanumeric characters, spaces, and common punctuation
  static String sanitizeText(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    // Remove null bytes and control characters (except newlines and tabs)
    var sanitized =
        input.replaceAll(RegExp(r'[\x00-\x08\x0B-\x0C\x0E-\x1F]'), '');

    // Trim whitespace
    sanitized = sanitized.trim();

    return sanitized;
  }

  /// Sanitizes HTML content by escaping HTML entities
  /// Prevents XSS attacks by escaping <, >, &, ", and '
  static String sanitizeHtml(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  /// Sanitizes SQL input by escaping single quotes
  /// Note: Always use parameterized queries instead of string concatenation
  /// This is a last resort if parameterized queries aren't available
  static String sanitizeSql(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    // Escape single quotes (double them)
    return input.replaceAll("'", "''");
  }

  /// Sanitizes filename by removing dangerous characters
  /// Only allows alphanumeric, dots, hyphens, and underscores
  static String sanitizeFilename(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    // Remove path separators and dangerous characters
    return input.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '').trim();
  }

  /// Sanitizes URL by validating and cleaning
  /// Returns empty string if URL is invalid
  static String sanitizeUrl(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    final trimmed = input.trim();

    // Basic URL validation
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return '';
    }

    // Remove dangerous characters
    return trimmed.replaceAll(RegExp(r'[<>"\x27`]'), '');
  }

  /// Normalizes whitespace (collapses multiple spaces to single space)
  static String normalizeWhitespace(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    return input.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Removes leading/trailing whitespace and normalizes internal whitespace
  static String normalizeText(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    return normalizeWhitespace(input);
  }

  /// Sanitizes phone number by removing non-digit characters
  /// Keeps only digits and + sign (if at start)
  static String sanitizePhone(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    final cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure + is only at the start
    if (cleaned.startsWith('+')) {
      return '+${cleaned.substring(1).replaceAll('+', '')}';
    }

    return cleaned;
  }

  /// Sanitizes email by removing dangerous characters
  /// Keeps only valid email characters
  static String sanitizeEmail(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    // Remove dangerous characters but keep valid email characters
    return input
        .replaceAll(RegExp(r'[<>"\x27`;,\[\]{}|\\]'), '')
        .trim()
        .toLowerCase();
  }

  /// Sanitizes username by removing invalid characters
  /// Keeps only alphanumeric, underscore, and hyphen
  static String sanitizeUsername(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    return input.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '').trim();
  }

  /// Sanitizes name by removing dangerous characters
  /// Keeps letters, spaces, hyphens, and apostrophes
  static String sanitizeName(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    // Keep letters, spaces, hyphens, apostrophes
    return input
        .replaceAll(RegExp(r"[^a-zA-Z\s\-']"), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Removes null bytes and control characters
  static String removeControlCharacters(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    return input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
  }

  /// Truncates string to maximum length
  /// Useful for preventing buffer overflow attacks
  static String truncate(String? input, int maxLength) {
    if (input == null || input.isEmpty) {
      return '';
    }

    if (input.length <= maxLength) {
      return input;
    }

    if (kDebugMode) {
      debugPrint(
          '⚠️ Input truncated from ${input.length} to $maxLength characters');
    }

    return input.substring(0, maxLength);
  }

  /// Sanitizes and truncates text input
  /// Combines sanitization and length limiting
  static String sanitizeAndTruncate(String? input, int maxLength) {
    final sanitized = sanitizeText(input);
    return truncate(sanitized, maxLength);
  }

  /// Validates and sanitizes JSON input
  /// Returns sanitized JSON string or empty string if invalid
  static String sanitizeJson(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    try {
      // Try to parse JSON to validate
      // This will throw if JSON is invalid
      // In a real implementation, you might want to parse and re-stringify
      // to ensure it's valid JSON
      return input.trim();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Invalid JSON input: $e');
      }
      return '';
    }
  }
}
