# Release Build Security Configuration

This document describes the security hardening measures implemented for release builds to prevent reverse engineering and protect the application.

## Overview

The Android build configuration has been hardened with:
- **Code obfuscation** via ProGuard
- **Code minification** to reduce APK size and make reverse engineering harder
- **Resource shrinking** to remove unused resources
- **Release signing** with proper keystore (separate from debug keys)
- **Flutter obfuscation** for Dart code

## Android Build Configuration

### 1. Release Signing Setup

**IMPORTANT**: You must create a release keystore before building for production.

#### Step 1: Generate a Keystore

```bash
keytool -genkey -v -keystore ~/ozpos-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ozpos
```

This will prompt you for:
- Keystore password
- Key password (can be same as keystore password)
- Your name, organization, city, state, country code

**SECURITY**: Store this keystore file securely and back it up! If you lose it, you cannot update your app on Google Play.

#### Step 2: Create keystore.properties

1. Copy `android/keystore.properties.example` to `android/keystore.properties`
2. Update the values with your actual credentials:

```properties
keyAlias=ozpos
keyPassword=YOUR_KEY_PASSWORD
storeFile=../ozpos-release-key.jks
storePassword=YOUR_KEYSTORE_PASSWORD
```

**SECURITY**: The `keystore.properties` file is in `.gitignore` - NEVER commit it!

#### Step 3: Verify Signing

The build will automatically use the release signing config if `keystore.properties` exists. If it doesn't exist, it will fall back to debug signing (for development only).

### 2. ProGuard Configuration

ProGuard rules are defined in `android/app/proguard-rules.pro`. This file:
- Keeps necessary Flutter classes
- Obfuscates application code
- Removes unused code
- Optimizes bytecode

The rules are automatically applied during release builds.

### 3. Build Types

#### Release Build
- ✅ Code minification enabled
- ✅ Resource shrinking enabled
- ✅ ProGuard obfuscation enabled
- ✅ Debug features disabled
- ✅ Release signing (if keystore configured)

#### Debug Build
- ❌ No minification (for faster builds)
- ❌ No obfuscation (for easier debugging)
- ✅ Debug signing
- ✅ Debug features enabled

## Flutter Obfuscation

Flutter provides additional obfuscation for Dart code. This is separate from Android's ProGuard.

### Building with Flutter Obfuscation

**For APK:**
```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

**For App Bundle (Google Play):**
```bash
flutter build appbundle --release --obfuscate --split-debug-info=./debug-info
```

### What This Does

- **`--obfuscate`**: Obfuscates Dart code, making it harder to reverse engineer
- **`--split-debug-info=./debug-info`**: Extracts debug symbols to a separate directory

**IMPORTANT**: Save the `debug-info` directory! You'll need it for:
- Crash symbolication (to read stack traces)
- Debugging production issues

### Debug Info Management

The debug info files are stored in the specified directory (e.g., `./debug-info`). These files:
- Should be stored securely (they're in `.gitignore`)
- Are needed to symbolicate crash reports
- Should be backed up with your keystore

To symbolicate a crash report:
```bash
flutter symbolize -i <stack-trace-file> -d ./debug-info
```

## Complete Release Build Process

### 1. Ensure Keystore is Configured

Verify `android/keystore.properties` exists and is correctly configured.

### 2. Build Release APK

```bash
# With Flutter obfuscation (recommended)
flutter build apk --release --obfuscate --split-debug-info=./debug-info

# Without Flutter obfuscation (faster, less secure)
flutter build apk --release
```

### 3. Build App Bundle (for Google Play)

```bash
# With Flutter obfuscation (recommended)
flutter build appbundle --release --obfuscate --split-debug-info=./debug-info

# Without Flutter obfuscation
flutter build appbundle --release
```

### 4. Verify Build

Check the build output:
- APK location: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle location: `build/app/outputs/bundle/release/app-release.aab`

You can verify the signing:
```bash
# For APK
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# For App Bundle (requires bundletool)
```

## Security Best Practices

### ✅ DO:
- Always use release signing for production builds
- Enable obfuscation for production releases
- Store keystore and debug-info securely
- Back up keystore and passwords
- Use strong passwords for keystore
- Test release builds before publishing

### ❌ DON'T:
- Commit keystore files or passwords to version control
- Use debug signing for production
- Share keystore files or passwords
- Build release without obfuscation (unless necessary)
- Lose your keystore (you can't update the app without it!)

## Troubleshooting

### Build Fails: "Keystore file not found"
- Ensure `keystore.properties` exists in `android/` directory
- Check that `storeFile` path in `keystore.properties` is correct
- Use absolute path if relative path doesn't work

### Build Fails: "Signing config not found"
- Verify `keystore.properties` has all required fields
- Check that keystore file exists at the specified path
- Ensure passwords are correct

### ProGuard Errors
- Check `proguard-rules.pro` for missing keep rules
- Add keep rules for classes that ProGuard is removing incorrectly
- Test thoroughly after adding ProGuard rules

### App Crashes After Obfuscation
- Check ProGuard rules - may need to keep additional classes
- Verify Flutter obfuscation didn't break reflection-based code
- Test release builds thoroughly before publishing

## Additional Resources

- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [ProGuard Manual](https://www.guardsquare.com/manual/home)
- [Flutter Build Modes](https://docs.flutter.dev/testing/build-modes)
- [Flutter Obfuscation](https://docs.flutter.dev/deployment/obfuscate)

