## iMin Printer Integration (Basic Guide)

This document explains in a simple way how the `imin_printer` package is used in this app to print on iMin devices.

---

### 1. Dependency

We use a **local override** of the iMin printer plugin (to resolve conflicts with `imin_hardware_plugin`):

```yaml
dependencies:
  imin_printer:
    path: local_packages/imin_printer
```

See [imin_conflict_resolution.md](imin_conflict_resolution.md) for why we use a local copy. This gives us access to the `IminPrinter` class and related enums/styles.

---

### 2. Service Wrapper: `IminPrinterService`

File: `lib/features/printing/data/services/imin_printer_service.dart`

We created a small wrapper class around the plugin:

- Holds a single `IminPrinter` instance.
- Makes sure the printer is **initialized once**.
- Exposes **very simple methods** for the rest of the app to call:
  - `printTestReceipt()`
  - `printOrderReceipt(String receiptText)`
  - `openCashDrawer()`

Key ideas:

```dart
class IminPrinterService {
  final IminPrinter _iminPrinter = IminPrinter();
  bool _initialized = false;

  Future<bool> _ensureInitialized() async {
    // Only works on Android. On other platforms, we just return false.
    if (!Platform.isAndroid) return false;

    if (_initialized) return true;

    await _iminPrinter.initPrinter();
    _initialized = true;
    return true;
  }
}
```

- `_ensureInitialized()` is called by all public methods.
- If init fails or we are not on Android, methods simply return `false` instead of crashing.

#### 2.1 `printTestReceipt`

`printTestReceipt` is a simple “hello world” for the iMin printer:

- Initializes the printer.
- Prints:
  - A big `=== TEST RECEIPT ===` title.
  - Printer name.
  - Current date/time.
  - A short message: “This is a test print from OZPOS.”
- Feeds some paper and ends the job.

Use case: quick check that the built‑in printer is working.

#### 2.2 `printOrderReceipt`

`printOrderReceipt(String receiptText)` is used for **real receipts**:

- `receiptText` is a plain multi‑line string (same format used for network ESC/POS printers).
- We:
  - Split by `\n`.
  - For each non‑empty line, call `printText` with word‑wrap and left alignment.
  - For empty lines, call `printAndLineFeed()` to add spacing.
  - At the end, feed some extra paper and send a newline in raw data.

This keeps your receipt layout logic in one place (string building), and the iMin printer just prints it line by line.

#### 2.3 `openCashDrawer`

`openCashDrawer()` simply:

- Ensures the printer is initialized.
- Calls `openCashBox()` from the plugin.
- Returns `true`/`false` depending on success.

---

### 3. Dependency Injection (GetIt)

File: `lib/core/di/modules/printing_module.dart`

We register the `IminPrinterService` in the printing DI module:

```dart
sl.registerLazySingleton<IminPrinterService>(
  () => IminPrinterService(),
);
```

This allows any part of the app to access the service with:

```dart
final iminPrinterService = sl<IminPrinterService>();
```

---

### 4. How the App Uses iMin Printer (Checkout Flow)

File: `lib/features/checkout/presentation/screens/checkout_screen.dart`

When checkout succeeds (`CheckoutSuccess` state), the flow is now:

1. Build the receipt text (already implemented).
2. Load printers from `PrintingRepository`.
3. Try to find a **network receipt printer** (ESC/POS).
   - If found, use the existing `NetworkPrinterService.printOrderReceipt(...)`.
4. **If no network receipt printer is configured**, try the iMin printer:

```dart
final iminPrinterService = sl<IminPrinterService>();

// If there is no network receipt printer, fall back to iMin.
iminPrinterService
    .printOrderReceipt(receiptText)
    .then((printed) {
  if (!printed && context.mounted) {
    // Optional snackbar to say nothing was available.
  }
  clearAndNavigate();
}).catchError((_) {
  clearAndNavigate();
});
```

So:

- Network printers keep working like before.
- On an iMin Android terminal with no network printer set up, the app will still try to print the receipt using the built‑in printer.

---

### 5. How to Manually Test iMin Printer

You can manually call the service from anywhere in the app where `GetIt` is available:

```dart
final iminService = sl<IminPrinterService>();

// Simple test:
await iminService.printTestReceipt();

// Print a custom text receipt:
await iminService.printOrderReceipt('Hello iMin!\nThank you for your order.');

// Open cash drawer:
await iminService.openCashDrawer();
```

Remember: all these calls only do real work on **Android iMin devices**. On other platforms they safely return `false`.

---

### 6. Summary (Very Simple)

- We installed `imin_printer` in `pubspec.yaml`.
- We wrapped the plugin in a small `IminPrinterService` with 3 basic methods:
  - `printTestReceipt`
  - `printOrderReceipt`
  - `openCashDrawer`
- We registered the service in the DI container (`GetIt`).
- In checkout:
  - The app first tries a configured network receipt printer.
  - If none is available, it falls back to the iMin built‑in printer.

