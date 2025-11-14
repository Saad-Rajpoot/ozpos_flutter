# Input Validation and Sanitization Security

This document describes the comprehensive input validation and sanitization system implemented to prevent injection attacks and ensure data integrity.

## Overview

The application now includes a robust input validation and sanitization system that:
- **Validates** user input before processing
- **Sanitizes** input to remove dangerous characters
- **Prevents** SQL injection, XSS, and command injection attacks
- **Enforces** length limits and format requirements
- **Normalizes** data for consistent storage

## Validation System

### Core Validators (`lib/core/validation/input_validators.dart`)

The `InputValidators` class provides comprehensive validation functions:

#### Basic Validators

- **`required(value, fieldName?)`**: Validates non-empty field
- **`minLength(value, min, fieldName?)`**: Validates minimum length
- **`maxLength(value, max, fieldName?)`**: Validates maximum length
- **`lengthRange(value, min, max, fieldName?)`**: Validates length range

#### Format Validators

- **`email(value, fieldName?)`**: Validates email format (RFC 5322 compliant)
- **`phone(value, fieldName?)`**: Validates phone number format (international)
- **`numeric(value, fieldName?)`**: Validates numeric input
- **`integer(value, fieldName?)`**: Validates integer input
- **`positiveNumber(value, fieldName?)`**: Validates positive numbers
- **`numberRange(value, min, max, fieldName?)`**: Validates number range
- **`url(value, fieldName?)`**: Validates URL format

#### Character Set Validators

- **`alphanumeric(value, fieldName?)`**: Only letters and numbers
- **`alphabetic(value, fieldName?)`**: Only letters
- **`username(value, fieldName?)`**: Username format (3-30 chars, alphanumeric, underscore, hyphen)
- **`password(value, fieldName?)`**: Password strength (8+ chars, letter + number)

#### Security Validators

- **`noDangerousPatterns(value, fieldName?)`**: Detects SQL injection, XSS, and command injection patterns
- **`safeCharactersOnly(value, fieldName?)`**: Only allows safe characters

#### Domain-Specific Validators

- **`driverName(value)`**: Validates driver name (2-50 chars, letters, spaces, hyphens, apostrophes)
- **`driverPhone(value)`**: Validates driver phone number
- **`driverEmail(value)`**: Validates driver email (optional)
- **`driverUsername(value)`**: Validates driver username (optional)

#### Utility Functions

- **`combine(validators, value)`**: Combines multiple validators

## Sanitization System

### Core Sanitizers (`lib/core/validation/input_sanitizer.dart`)

The `InputSanitizer` class provides sanitization functions:

#### General Sanitization

- **`sanitizeText(input)`**: Removes control characters and trims
- **`normalizeWhitespace(input)`**: Collapses multiple spaces
- **`normalizeText(input)`**: Normalizes whitespace and trims
- **`removeControlCharacters(input)`**: Removes null bytes and control chars
- **`truncate(input, maxLength)`**: Truncates to maximum length
- **`sanitizeAndTruncate(input, maxLength)`**: Combines sanitization and truncation

#### Type-Specific Sanitization

- **`sanitizeName(input)`**: Sanitizes names (letters, spaces, hyphens, apostrophes)
- **`sanitizePhone(input)`**: Sanitizes phone numbers (digits and +)
- **`sanitizeEmail(input)`**: Sanitizes email addresses
- **`sanitizeUsername(input)`**: Sanitizes usernames (alphanumeric, underscore, hyphen)
- **`sanitizeFilename(input)`**: Sanitizes filenames
- **`sanitizeUrl(input)`**: Sanitizes URLs

#### Security Sanitization

- **`sanitizeHtml(input)`**: Escapes HTML entities (prevents XSS)
- **`sanitizeSql(input)`**: Escapes SQL quotes (use parameterized queries instead!)

## Usage Examples

### Basic Form Validation

```dart
TextFormField(
  controller: _nameController,
  validator: InputValidators.driverName,
  onChanged: (value) {
    // Real-time sanitization
    if (value.isNotEmpty) {
      final sanitized = InputSanitizer.sanitizeName(value);
      if (sanitized != value) {
        // Update controller with sanitized value
      }
    }
  },
)
```

### Combined Validators

```dart
validator: (value) => InputValidators.combine([
  (v) => InputValidators.required(v, fieldName: 'Email'),
  (v) => InputValidators.email(v),
  (v) => InputValidators.maxLength(v, 254),
], value),
```

### Custom Validator

```dart
validator: (value) {
  // Check required
  final requiredError = InputValidators.required(value, fieldName: 'Phone');
  if (requiredError != null) return requiredError;
  
  // Check format
  final formatError = InputValidators.phone(value);
  if (formatError != null) return formatError;
  
  // Check for dangerous patterns
  final securityError = InputValidators.noDangerousPatterns(value);
  if (securityError != null) return securityError;
  
  return null;
},
```

### Sanitization Before Submission

```dart
void _saveForm() {
  if (_formKey.currentState!.validate()) {
    final sanitizedData = {
      'name': InputSanitizer.sanitizeName(_nameController.text),
      'phone': InputSanitizer.sanitizePhone(_phoneController.text),
      'email': InputSanitizer.sanitizeEmail(_emailController.text),
      'username': InputSanitizer.sanitizeUsername(_usernameController.text),
    };
    
    // Send sanitized data to backend
    _submitData(sanitizedData);
  }
}
```

## Security Features

### SQL Injection Prevention

The `noDangerousPatterns` validator detects:
- SQL keywords: `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `DROP`, etc.
- SQL operators: `UNION`, `OR`, `AND` with numeric comparisons
- SQL delimiters: quotes, semicolons, comments (`--`, `/* */`)

**Important**: Always use parameterized queries in addition to validation!

### XSS Prevention

The validator detects:
- `<script>` tags
- `javascript:` protocol
- Event handlers: `onclick`, `onerror`, etc.
- `<iframe>` tags

The sanitizer escapes HTML entities:
- `<` → `&lt;`
- `>` → `&gt;`
- `&` → `&amp;`
- `"` → `&quot;`
- `'` → `&#x27;`

### Command Injection Prevention

The validator detects:
- Command separators: `;`, `&`, `|`, `` ` ``, `$`
- Common commands: `cat`, `ls`, `pwd`, `whoami`, `id`, `uname`
- Shell metacharacters: `()`, `{}`

### Length Limits

All inputs are validated for:
- Minimum length (prevents empty/incomplete data)
- Maximum length (prevents buffer overflow attacks)
- Truncation if exceeding limits

## Implementation in Forms

### Updated Form Example

The `add_driver_modal.dart` has been updated to use proper validators:

```dart
_buildTextField(
  'Driver Name *',
  _nameController,
  'Enter full name',
)
// Automatically uses InputValidators.driverName
```

The form now:
1. **Validates** on submit using appropriate validators
2. **Sanitizes** input in real-time as user types
3. **Checks** for dangerous patterns before submission
4. **Normalizes** data before sending to backend

## Best Practices

### ✅ DO:

- **Always validate** user input before processing
- **Sanitize** input before storing or displaying
- **Use type-specific** validators (email, phone, etc.)
- **Combine validators** for complex requirements
- **Check for dangerous patterns** in all text inputs
- **Enforce length limits** to prevent buffer overflows
- **Normalize data** for consistent storage
- **Use parameterized queries** for database operations (in addition to validation)

### ❌ DON'T:

- **Trust client-side validation alone** (always validate on backend too)
- **Skip sanitization** even if validation passes
- **Allow unlimited length** inputs
- **Ignore dangerous patterns** warnings
- **Use string concatenation** for SQL queries
- **Display unsanitized** user input in HTML
- **Store raw user input** without sanitization

## Testing

### Test Cases to Verify

1. **SQL Injection Attempts**:
   - `'; DROP TABLE users; --`
   - `1' OR '1'='1`
   - Should be rejected by `noDangerousPatterns`

2. **XSS Attempts**:
   - `<script>alert('XSS')</script>`
   - `javascript:alert('XSS')`
   - Should be rejected or sanitized

3. **Length Limits**:
   - Input exceeding max length should be truncated
   - Input below min length should be rejected

4. **Format Validation**:
   - Invalid email formats should be rejected
   - Invalid phone formats should be rejected
   - Invalid usernames should be rejected

5. **Sanitization**:
   - Dangerous characters should be removed
   - Control characters should be removed
   - Whitespace should be normalized

## Migration Guide

### Updating Existing Forms

1. **Import validators**:
   ```dart
   import '../../../../core/validation/input_validators.dart';
   import '../../../../core/validation/input_sanitizer.dart';
   ```

2. **Replace simple validators**:
   ```dart
   // Old
   validator: (value) {
     if (value == null || value.isEmpty) return 'Required';
     return null;
   }
   
   // New
   validator: InputValidators.driverName
   ```

3. **Add sanitization**:
   ```dart
   onChanged: (value) {
     if (value.isNotEmpty) {
       final sanitized = InputSanitizer.sanitizeName(value);
       // Update controller if sanitized differs
     }
   }
   ```

4. **Sanitize before submission**:
   ```dart
   final sanitizedData = {
     'name': InputSanitizer.sanitizeName(_nameController.text),
     // ... other fields
   };
   ```

## Additional Resources

- [OWASP Input Validation Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html)
- [OWASP XSS Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)
- [OWASP SQL Injection Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)
- [Flutter Form Validation](https://docs.flutter.dev/cookbook/forms/validation)

