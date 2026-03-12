import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:presentation_displays/displays_manager.dart';
import 'package:presentation_displays/display.dart';

import '../display/display_manager.dart';
import '../../features/checkout/presentation/bloc/cart_bloc.dart';

/// Drives the Android Presentation (secondary display) customer screen.
///
/// Source of truth remains the main POS cart (`CartBloc`).
/// The secondary Flutter engine receives updates via platform channel transfer.
class CustomerDisplayService {
  CustomerDisplayService({
    required CartBloc cartBloc,
    DisplayManager? displayManager,
  })  : _cartBloc = cartBloc,
        _displayManager = displayManager ?? sharedDisplayManager;

  final CartBloc _cartBloc;
  final DisplayManager _displayManager;

  StreamSubscription<CartState>? _cartSub;

  int? _activeDisplayId;
  bool _isStarted = false;
  int _lastSentItemsCount = -1;
  bool _isActivated = false;

  Future<void> start() async {
    if (_isStarted) return;
    _isStarted = true;

    if (!Platform.isAndroid) {
      if (kDebugMode) {
        debugPrint('CustomerDisplayService: start skipped (not Android)');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('CustomerDisplayService: starting (Android)');
    }

    _cartSub = _cartBloc.stream.listen((state) async {
      if (state is! CartLoaded) return;
      if (!_isActivated) return;
      await _pushCartUpdate(state);
    });

    // Initial attempt.
    await _ensurePresentationOpen();
  }

  Future<void> stop() async {
    _isStarted = false;
    await _cartSub?.cancel();
    _cartSub = null;

    _activeDisplayId = null;
  }

  Future<void> _ensurePresentationOpen() async {
    try {
      // Prefer the PRESENTATION category so we only target true external
      // presentation displays. Fall back to all displays only when the
      // category returns nothing.
      final presentationDisplays = await _displayManager.getDisplays(
        category: DISPLAY_CATEGORY_PRESENTATION,
      );

      final bool usedPresentationCategory =
          presentationDisplays != null && presentationDisplays.isNotEmpty;

      final displays = usedPresentationCategory
          ? presentationDisplays
          : await _displayManager.getDisplays();
      if (kDebugMode) {
        debugPrint(
          'CustomerDisplayService: getDisplays() -> '
          '${displays?.map((d) => '[id=${d.displayId}, name=${d.name}]').join(', ') ?? 'null'}',
        );
      }
      final secondary = _pickSecondaryDisplay(
        displays,
        usedPresentationCategory: usedPresentationCategory,
      );
      if (secondary == null) {
        // No secondary display: keep POS running normally.
        if (kDebugMode) {
          debugPrint('CustomerDisplayService: no secondary display detected');
        }
        _activeDisplayId = null;
        return;
      }

      final displayId = secondary.displayId;

      if (_activeDisplayId == displayId) {
        if (kDebugMode) {
          debugPrint(
            'CustomerDisplayService: already active on displayId=$displayId (${secondary.name})',
          );
        }
        return;
      }

      if (kDebugMode) {
        debugPrint(
          'CustomerDisplayService: showing secondary displayId=$displayId name=${secondary.name} routerName=customerDisplayMain',
        );
      }
      final ok = await _displayManager.showSecondaryDisplay(
        displayId: displayId,
        routerName: 'customerDisplayMain',
      );

      if (ok == true) {
        if (kDebugMode) {
          debugPrint('CustomerDisplayService: showSecondaryDisplay OK ($displayId)');
        }
        _activeDisplayId = displayId;
      } else {
        if (kDebugMode) {
          debugPrint('CustomerDisplayService: showSecondaryDisplay FAILED ($displayId) -> $ok');
        }
        _activeDisplayId = null;
      }
    } catch (e) {
      // Never crash the POS if presentation APIs fail.
      if (kDebugMode) {
        debugPrint('CustomerDisplayService: failed to open presentation: $e');
      }
      _activeDisplayId = null;
    }
  }

  Display? _pickSecondaryDisplay(
    List<Display>? displays, {
    required bool usedPresentationCategory,
  }) {
    if (displays == null || displays.isEmpty) return null;

    // If we queried using PRESENTATION category, the list already contains
    // only suitable external displays, sorted by preference. Just use the
    // first one.
    if (usedPresentationCategory) {
      return displays.first;
    }

    // Fallback (no PRESENTATION displays reported):
    // Treat only non-primary displays as potential secondary targets.
    // DEFAULT_DISPLAY (0) is the built‑in screen; we must not attach the
    // presentation there or the POS appears "replaced" on single‑screen
    // devices.
    final nonPrimary = displays
        .where((d) => d.displayId != DEFAULT_DISPLAY)
        .toList(growable: false);
    if (nonPrimary.isNotEmpty) return nonPrimary.first;

    // Only the primary display is available -> no secondary display.
    return null;
  }

  Future<void> _pushCartUpdate(
    CartLoaded cart, {
    String status = 'order',
    String? paymentType,
    double? changeDue,
  }) async {
    // Don't switch away from promo slides until the POS "activates" the display
    // by opening the menu/checkout flow.
    if (!_isActivated && status == 'order') return;

    // If a display becomes available after startup, open it on demand.
    if (_activeDisplayId == null) {
      await _ensurePresentationOpen();
    }
    if (_activeDisplayId == null) return;

    final payload = <String, dynamic>{
      'type': 'cart_update',
      'storeName': 'OZPOS',
      'items': cart.items
          .map(
            (i) => {
              'id': i.id,
              'name': i.menuItem.name,
              'quantity': i.quantity,
              'unitPrice': i.unitPrice,
              'modifierSummary': i.modifierSummary,
            },
          )
          .toList(growable: false),
      'subtotal': cart.subtotal,
      'tax': cart.gst,
      'total': cart.total,
      'status': status,
      'paymentType': paymentType,
      'changeDue': changeDue,
      'ts': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      if (kDebugMode && _lastSentItemsCount != cart.items.length) {
        _lastSentItemsCount = cart.items.length;
        debugPrint(
          'CustomerDisplayService: transfer cart_update to displayId=$_activeDisplayId '
          '(items=${cart.items.length}, total=${cart.total}, '
          'status=$status, paymentType=$paymentType, changeDue=$changeDue)',
        );
      }
      await _displayManager.transferDataToPresentation(payload);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CustomerDisplayService: transfer failed: $e');
      }
      // Drop the active id; next update/display change will attempt reopen.
      _activeDisplayId = null;
    }
  }
}

/// High-level helpers for driving the full customer display flow from the POS.
///
/// Use these in checkout/payment flows so the customer-facing screen shows
/// the correct step: order review, payment (card/cash), approval, change due,
/// or error.
extension CustomerDisplayServiceFlows on CustomerDisplayService {
  /// Show the normal order review screen.
  Future<void> showOrderView() async {
    _isActivated = true;
    final state = _cartBloc.state;
    if (state is! CartLoaded) return;
    await _pushCartUpdate(state, status: 'order');
  }

  /// Show the blue card payment screen.
  Future<void> showCardPaymentView() async {
    _isActivated = true;
    final state = _cartBloc.state;
    if (state is! CartLoaded) return;
    await _pushCartUpdate(
      state,
      status: 'payment_card',
      paymentType: 'card',
    );
  }

  /// Show the green cash payment screen.
  Future<void> showCashPaymentView() async {
    _isActivated = true;
    final state = _cartBloc.state;
    if (state is! CartLoaded) return;
    await _pushCartUpdate(
      state,
      status: 'payment_cash',
      paymentType: 'cash',
    );
  }

  /// Show the “approved / thank you” screen.
  Future<void> showPaymentApprovedView({
    required String paymentType,
  }) async {
    _isActivated = true;
    final state = _cartBloc.state;
    if (state is! CartLoaded) return;
    await _pushCartUpdate(
      state,
      status: 'approved',
      paymentType: paymentType,
    );
  }

  /// Show the “change due” screen (for cash or mixed tenders).
  Future<void> showChangeDueView({
    required double changeDue,
  }) async {
    _isActivated = true;
    final state = _cartBloc.state;
    if (state is! CartLoaded) return;
    await _pushCartUpdate(
      state,
      status: 'change_due',
      paymentType: 'cash',
      changeDue: changeDue,
    );
  }

  /// Show the red “payment declined / error” screen.
  Future<void> showPaymentErrorView() async {
    _isActivated = true;
    final state = _cartBloc.state;
    if (state is! CartLoaded) return;
    await _pushCartUpdate(
      state,
      status: 'error',
    );
  }
}

