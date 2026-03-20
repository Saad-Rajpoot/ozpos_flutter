# iMin Package Conflict Resolution

This document explains the Android dependency conflict between `imin_printer` and `imin_hardware_plugin` when used together, and how it was resolved in this project.

---

## 1. Root Cause

### The Conflict

When both packages are used in the same Flutter app:

- **imin_printer** (^0.6.14) includes `IminStraElectronicSDK_V1.2.jar` in its Android `build.gradle`.
- **imin_hardware_plugin** (^1.0.4) includes its own electronic scale module (`IminScaleNew` / scale SDK) for Android 13+.
- Both ship native dependencies related to **weighing scales / electronic scale** hardware.
- This leads to:
  - Duplicate class errors during the Android build
  - Conflicting JARs or overlapping native libraries
  - Build failures when assembling the APK

### Why It Happens

- `IminStraElectronicSDK` = iMin’s electronic/weighing scale SDK.
- `imin_hardware_plugin` uses a similar or overlapping scale SDK for `IminScaleNew`.
- When both are on the classpath, the same classes or resources can be defined twice, causing merge conflicts.

### What We Need vs. Don’t Need

- **We need:** Printer, dual screen, cash drawer, lights, scanner, NFC, etc.
- **We do not need:** Weighing-scale / electronic scale support.
- So we can remove the weighing-related dependency from one of the packages without losing the features we use.

---

## 2. Solution: Local imin_printer Override

We use a **local path override** of `imin_printer` with the conflicting dependency removed.

### 2.1 Project Layout

```
ozpos_flutter/
├── local_packages/
│   └── imin_printer/          # Cloned from github.com/iminsoftware/imin_printer
│       ├── android/
│       │   └── build.gradle   # Modified: IminStraElectronicSDK line removed
│       ├── lib/
│       └── pubspec.yaml
├── pubspec.yaml               # Uses path: local_packages/imin_printer
└── ...
```

### 2.2 Change in `local_packages/imin_printer/android/build.gradle`

**Before:**
```gradle
implementation files('libs/IminStraElectronicSDK_V1.2.jar')
```

**After:**
```gradle
// REMOVED: IminStraElectronicSDK_V1.2.jar - Electronic/weighing scale SDK.
// This JAR conflicts with imin_hardware_plugin's scale module when both packages
// are used together. We do not need weighing-scale support; printer works without it.
// implementation files('libs/IminStraElectronicSDK_V1.2.jar')
```

### 2.3 pubspec.yaml Configuration

```yaml
dependencies:
  # Local override: imin_printer with IminStraElectronicSDK removed
  imin_printer:
    path: local_packages/imin_printer
  imin_hardware_plugin: ^1.0.4
```

---

## 3. What Changed

| Area | Change |
|------|--------|
| **imin_printer** | Switched from pub.dev to local path; `IminStraElectronicSDK` removed from Android deps |
| **IminPrinterService** | Restored and wired for printer, test receipt, order receipt, cash drawer |
| **Checkout flow** | Uses iMin printer as fallback when no network receipt printer is configured |
| **Printing Management** | Added “iMin Built-in Printer” card with “Test Print” button |
| **imin_hardware_plugin** | Unchanged; used for display, cash drawer, lights, etc. |

---

## 4. Why It Works

1. **No duplicate scale SDKs:** Only `imin_hardware_plugin` brings scale-related code; we don’t use it, but it no longer clashes with `imin_printer`.
2. **Printer still works:** `imin_printer` depends on `iminPrinterSDK` and `IminPrinterLibrary`; neither requires `IminStraElectronicSDK` for printing.
3. **Cash drawer still works:** iMin cash drawer is available via both `IminPrinterService.openCashDrawer()` (imin_printer) and `IminHardwareService.openCashDrawer()` (imin_hardware_plugin).

---

## 5. Tradeoffs

| Tradeoff | Impact |
|----------|--------|
| **No weighing-scale support** | Intended; we don’t use it. |
| **Local package maintenance** | We must update `local_packages/imin_printer` when upstream fixes bugs or adds printer features. |
| **Upstream updates** | Need to re-apply the `IminStraElectronicSDK` removal when pulling new imin_printer versions. |

---

## 6. How to Maintain and Update

### Updating the Local imin_printer

1. Go to `local_packages/imin_printer`.
2. Pull upstream: `git pull origin master` (or the branch you track).
3. Ensure `android/build.gradle` still has the `IminStraElectronicSDK` line commented out or removed.
4. Run `flutter pub get` and `flutter build apk` to confirm the build succeeds.

### If Upstream Fixes the Conflict

If a future `imin_printer` version drops or makes `IminStraElectronicSDK` optional:

1. Switch back to pub.dev: `imin_printer: ^x.y.z`.
2. Remove the `path` override and the `local_packages/imin_printer` folder.
3. Run `flutter pub get` and `flutter build apk`.

### Recreating the Local Package from Scratch

```bash
# From project root
rm -rf local_packages/imin_printer
git clone --depth 1 https://github.com/iminsoftware/imin_printer.git local_packages/imin_printer

# Then edit local_packages/imin_printer/android/build.gradle
# and comment out the IminStraElectronicSDK line as shown above.
```

---

## 7. Summary

- **Root cause:** Both `imin_printer` and `imin_hardware_plugin` pull in electronic/weighing scale dependencies that conflict.
- **Fix:** Use a local `imin_printer` with `IminStraElectronicSDK` removed.
- **Result:** Printer and non-weighing hardware (display, cash drawer, lights, etc.) work together without build conflicts.
- **Maintenance:** Re-apply the Gradle change when updating the local `imin_printer` copy.
