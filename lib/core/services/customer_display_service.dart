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
      await _pushCartUpdate(state);
    });

    // Initial attempt.
    await _ensurePresentationOpen();

    // Push the current cart state immediately (if available).
    final state = _cartBloc.state;
    if (state is CartLoaded) {
      await _pushCartUpdate(state);
    }
  }

  Future<void> stop() async {
    _isStarted = false;
    await _cartSub?.cancel();
    _cartSub = null;

    _activeDisplayId = null;
  }

  Future<void> _ensurePresentationOpen() async {
    try {
      final displays = await _displayManager.getDisplays();
      if (kDebugMode) {
        debugPrint(
          'CustomerDisplayService: getDisplays() -> '
          '${displays?.map((d) => '[id=${d.displayId}, name=${d.name}]').join(', ') ?? 'null'}',
        );
      }
      final secondary = _pickSecondaryDisplay(displays);
      if (secondary == null) {
        // No secondary display: keep POS running normally.
        if (kDebugMode) {
          debugPrint('CustomerDisplayService: no secondary display detected');
        }
        _activeDisplayId = null;
        return;
      }

      final displayId = secondary.displayId;
      if (displayId == null) {
        if (kDebugMode) {
          debugPrint('CustomerDisplayService: secondary displayId is null');
        }
        return;
      }

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

  Display? _pickSecondaryDisplay(List<Display>? displays) {
    if (displays == null || displays.isEmpty) return null;

    // If we queried using PRESENTATION category, we might only get the external
    // display list. In that case, just use the first.
    if (displays.length == 1) {
      return displays.first;
    }

    // For Android "Simulate secondary displays", IDs are not guaranteed to use 0
    // for primary. The most reliable heuristic is: if multiple displays exist,
    // treat the 2nd display as the presentation target.
    if (displays.length >= 2) {
      return displays[1];
    }

    // Fallback: try to pick a non-zero id (some devices expose primary as 0).
    final nonZero =
        displays.where((d) => (d.displayId ?? 0) != 0).toList(growable: false);
    if (nonZero.isNotEmpty) return nonZero.first;

    // If plugin only returns one display, treat as no secondary.
    return null;
  }

  Future<void> _pushCartUpdate(
    CartLoaded cart, {
    String status = 'order',
    String? paymentType,
    double? changeDue,
  }) async {
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
    final state = _cartBloc.state;
    if (state is! CartLoaded) return;
    await _pushCartUpdate(state, status: 'order');
  }

  /// Show the blue card payment screen.
  Future<void> showCardPaymentView() async {
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
    final state = _cartBloc.state;
    if (state is! CartLoaded) return;
    await _pushCartUpdate(
      state,
      status: 'error',
    );
  }
}

