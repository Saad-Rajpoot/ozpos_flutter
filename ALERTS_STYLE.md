## Global Alert/Toast Rules

This project uses a single global toast style for **all alert-type messages** (required options, limits, cart removals, etc.). The visual pattern is:

- Top-right floating card
- Colored background (orange for warnings, red for errors)
- White circular icon with `!`
- Bold title, then supporting message and optional bullet list

The canonical implementation of this pattern is `LimitReachedToast` in `lib/core/widgets/limit_reached_toast.dart`. **Do not** hand-roll new `SnackBar` or `AlertDialog` styles for these cases.

### When to use the global alert toast

- **Validation failures**  
  - Missing required modifiers/options (e.g. “Required options – Please select: • Choose Size”)
  - Reaching a max selection limit for a modifier group
- **Business-rule warnings**  
  - Cart items automatically removed because the menu/time window has changed
  - Cart cleared because the active menu has switched to a different schedule
- **Non-blocking but important warnings**  
  - Anything that should be very visible but doesn’t need a full-screen dialog

### How to show an alert

Use `LimitReachedToast.show` and pass in the content instead of building a `SnackBar` manually:

```dart
LimitReachedToast.show(
  context,
  title: 'Required options',
  message: 'Please select:',
  bulletItems: ['Choose Size'],
  backgroundColor: AppColors.error, // red variant for hard errors
);
```

For generic warnings (like cart clean-up or limit reached), use the default orange background:

```dart
LimitReachedToast.show(
  context,
  title: 'Items removed',
  message: 'Some items are no longer available and were removed from your cart.',
  // backgroundColor omitted → uses default orange
);
```

### Do NOT use this pattern for

- Success toasts like “Order completed” (these can remain simple `SnackBar`s or a separate success pattern).
- Long, multi-step flows that deserve a dedicated dialog or screen.

### Implementation checklist for new alerts

1. **Never** instantiate a raw `SnackBar` for validation/business-rule warnings.
2. Always call `LimitReachedToast.show` with:
   - `title` – short, strong heading (“Required options”, “Limit reached”, “Items removed”, etc.)
   - `message` – 1–2 sentence explanation
   - `bulletItems` – optional, for listing specific missing items
   - `backgroundColor` – use `AppColors.error` for errors; omit for orange warning style
3. Keep messages concise; if more detail is required, link to or open a proper dialog.

