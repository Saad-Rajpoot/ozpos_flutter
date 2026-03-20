## iMin Hardware Plugin Integration (Basic Guide)

This document explains in simple terms how the `imin_hardware_plugin: ^1.0.4` package is used in this app, focusing on:

- **Secondary display control**
- **Cash drawer control**

---

### 1. Dependency

We added the official iMin hardware plugin to `pubspec.yaml`:

```yaml
dependencies:
  imin_hardware_plugin: ^1.0.4
```

This gives access to many hardware modules. In this project we mainly use:

- `IminDisplay` – controls the **secondary display** on iMin POS devices.
- `IminCashBox` – controls the **cash drawer**.

---

### 2. Service Wrapper: `IminHardwareService`

File: `lib/core/services/imin_hardware_service.dart`

We created a small wrapper class around the plugin:

- Keeps all **iMin‑specific hardware calls in one place**.
- Makes sure everything is **safe on non‑Android platforms** (methods just return `false` instead of crashing).
- Exposes **very simple methods**:
  - `openCashDrawer()`
  - `enableSecondaryDisplay()`
  - `disableSecondaryDisplay()`

Basic structure:

```dart
class IminHardwareService {
  IminHardwareService();

  bool get _isAndroid => Platform.isAndroid;

  Future<bool> openCashDrawer() async {
    if (!_isAndroid) return false;
    return await IminCashBox.open();
  }

  Future<bool> enableSecondaryDisplay() async {
    if (!_isAndroid) return false;
    final available = await IminDisplay.isAvailable();
    if (!available) return false;
    return await IminDisplay.enable();
  }

  Future<bool> disableSecondaryDisplay() async {
    if (!_isAndroid) return false;
    await IminDisplay.disable();
    return true;
  }
}
```

So the rest of the app does **not** talk to the plugin directly; it just calls this service.

---

### 3. Cash Drawer Control

**Goal:** be able to open the cash drawer reliably on iMin devices.

Implementation:

- The `openCashDrawer()` method inside `IminHardwareService` uses the plugin’s static API:

```dart
Future<bool> openCashDrawer() async {
  if (!_isAndroid) return false;
  try {
    return await IminCashBox.open();
  } catch (e) {
    // Log in debug mode, but never crash the POS
    return false;
  }
}
```

Notes:

- On **Android / iMin POS**: this will send the open command to the cash drawer.
- On **non‑Android platforms** (Windows, macOS, web, etc.): it simply returns `false` and does nothing.

To use it anywhere in the app:

```dart
final hw = sl<IminHardwareService>();
final ok = await hw.openCashDrawer();
```

You can call this right after a successful cash payment, for example.

---

### 4. Secondary Display Control

The app already has a full **customer display system** based on the `presentation_displays` package:

- `CustomerDisplayService` (`lib/core/services/customer_display_service.dart`) manages:
  - Finding a secondary display.
  - Opening a separate Flutter engine on it.
  - Sending cart and payment data to the customer‑facing UI.

The `imin_hardware_plugin` gives us **extra control** for iMin devices:

- `IminDisplay.isAvailable()` – check if a secondary display exists.
- `IminDisplay.enable()` – enable the secondary display.
- `IminDisplay.disable()` – disable it.
- `IminDisplay.showText() / showImage() / playVideo()` – show simple content.

In this app we:

- Wrap the key calls in `IminHardwareService`:

```dart
Future<bool> enableSecondaryDisplay() async {
  if (!_isAndroid) return false;
  try {
    final available = await IminDisplay.isAvailable();
    if (!available) return false;
    return await IminDisplay.enable();
  } catch (_) {
    return false;
  }
}

Future<bool> disableSecondaryDisplay() async {
  if (!_isAndroid) return false;
  try {
    await IminDisplay.disable();
    return true;
  } catch (_) {
    return false;
  }
}
```

- Keep using **`CustomerDisplayService`** + `presentation_displays` to actually render the **rich Flutter customer UI** on that secondary screen.

So:

- `IminDisplay` (via `IminHardwareService`) = low‑level iMin hardware control (on/off, availability).
- `CustomerDisplayService` = high‑level Flutter UI for the customer screen.

---

### 5. Dependency Injection (GetIt)

File: `lib/core/di/modules/customer_display_module.dart`

We register `IminHardwareService` in the customer display DI module:

```dart
sl.registerLazySingleton<IminHardwareService>(
  () => IminHardwareService(),
);
```

This makes it available app‑wide via:

```dart
final hw = sl<IminHardwareService>();
```

So any part of the app that needs iMin hardware (cash drawer, basic secondary display control) can use this service.

---

### 6. How to Use in the App (Examples)

**Open cash drawer after cash payment:**

```dart
final hw = sl<IminHardwareService>();
await hw.openCashDrawer();
```

**Enable secondary display when opening the menu / checkout:**

```dart
final hw = sl<IminHardwareService>();
await hw.enableSecondaryDisplay();

// Then rely on CustomerDisplayService to show the Flutter customer display UI.
```

**Disable secondary display when exiting the POS (optional):**

```dart
final hw = sl<IminHardwareService>();
await hw.disableSecondaryDisplay();
```

---

### 7. Summary (Very Simple)

- We installed `imin_hardware_plugin: ^1.0.4`.
- We created `IminHardwareService` to:
  - **Open the cash drawer** using `IminCashBox.open()`.
  - **Control the secondary display** (check availability, enable, disable) using `IminDisplay`.
- We registered the service in `GetIt` so it can be used from anywhere.
- For iMin devices, this works together with the existing customer display system to give:
  - Rich Flutter UI on the secondary screen.
  - Reliable cash drawer control.

