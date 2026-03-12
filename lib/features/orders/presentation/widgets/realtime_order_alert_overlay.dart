import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import 'order_alert_widget.dart';
import '../../../../core/navigation/app_router.dart';

/// Global overlay widget that listens to Firebase Realtime Database
/// `realtime-alerts/{vendor_uuid}/{branch_uuid}/{order_uuid}` and shows
/// the OrderAlertWidget anywhere in the app when a new alert arrives.
class RealtimeOrderAlertOverlay extends StatefulWidget {
  const RealtimeOrderAlertOverlay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<RealtimeOrderAlertOverlay> createState() =>
      _RealtimeOrderAlertOverlayState();
}

class _RealtimeOrderAlertOverlayState extends State<RealtimeOrderAlertOverlay> {
  StreamSubscription<DatabaseEvent>? _alertsSub;
  String? _lastCreatedAt;
  bool _isShowingAlert = false;
  bool _hasPrimedInitialValue = false;
  String? _refPath;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeRealtimeAlertsListener();
  }

  void _log(String message) {
    if (!kDebugMode) return;
    debugPrint('RealtimeOrderAlertOverlay: $message');
  }

  Future<void> _initializeRealtimeAlertsListener() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorUuid = prefs.getString(AppConstants.authVendorUuidKey);
      final branchUuid = prefs.getString(AppConstants.authBranchUuidKey);

      if (vendorUuid == null ||
          vendorUuid.isEmpty ||
          branchUuid == null ||
          branchUuid.isEmpty) {
        _log(
          'vendor/branch UUID missing, skipping listener '
          '(vendor="$vendorUuid", branch="$branchUuid").',
        );
        return;
      }

      _refPath = 'realtime-alerts/$vendorUuid/$branchUuid';
      _log('initializing listener at "$_refPath"');

      final ref = FirebaseDatabase.instance.ref(_refPath!);

      // Your firebase schema stores the latest alert as a single object directly
      // at `realtime-alerts/{vendor_uuid}/{branch_uuid}` (not nested by order id).
      // Listen to value changes and de-duplicate using `created_at`.
      _alertsSub = ref.onValue.listen(_handleAlertValueEvent);
    } catch (error, stackTrace) {
      _log('failed to init Firebase alert listener: $error');
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
    }
  }

  void _handleAlertValueEvent(DatabaseEvent event) {
    if (!mounted) {
      _log('onValue received but widget not mounted -> ignore');
      return;
    }
    final snapshot = event.snapshot;

    final value = snapshot.value;
    if (value == null) {
      _log('onValue snapshot is null -> ignore');
      return;
    }
    if (value is! Map) {
      _log('onValue snapshot is not a Map (type=${value.runtimeType}) -> ignore');
      return;
    }

    final data = Map<String, dynamic>.from(value as Map<Object?, Object?>);
    final createdAtStr = data['created_at'] as String? ?? '';
    final displayId = data['display_id'] as String?;
    final orderUuid = data['order_uuid'] as String?;

    _log(
      'onValue received created_at="$createdAtStr", display_id="$displayId", '
      'order_uuid="$orderUuid", lastCreatedAt="${_lastCreatedAt ?? ""}", '
      'primed=$_hasPrimedInitialValue, showing=$_isShowingAlert',
    );

    // Prime once with the current value so we don't show an alert immediately
    // on app startup for an already-existing node.
    if (!_hasPrimedInitialValue) {
      _hasPrimedInitialValue = true;
      _lastCreatedAt = createdAtStr.isEmpty ? null : createdAtStr;
      _log('primed initial value, will only show on subsequent changes');
      return;
    }

    // Skip duplicates / invalid payloads.
    if (createdAtStr.isEmpty || _lastCreatedAt == createdAtStr) {
      _log('duplicate/empty created_at -> ignore');
      return;
    }
    _lastCreatedAt = createdAtStr;

    if (_isShowingAlert) {
      // Avoid stacking dialogs; the newest alert will be shown after the
      // current one is dismissed when its created_at changes again.
      _log('alert already showing -> ignore this update');
      return;
    }

    final order = _mapAlertToOrderEntity(orderUuid ?? 'unknown', data);
    _isShowingAlert = true;

    final dialogContext = NavigationService.context;
    if (dialogContext == null) {
      _log('NavigationService.context is null -> cannot show dialog');
      _isShowingAlert = false;
      return;
    }

    _playAlertSound();
    _log('showing alert dialog for ${order.queueNumber} (orderId=${order.id})');
    showDialog<void>(
      context: dialogContext,
      barrierDismissible: false,
      builder: (ctx) => OrderAlertWidget(
        order: order,
        onAccept: () {
          Navigator.of(ctx).pop();
          NavigationService.pushNamed(AppRouter.orders);
        },
        onShowOrder: () {
          Navigator.of(ctx).pop();
          NavigationService.pushNamed(
            AppRouter.orders,
            arguments: <String, dynamic>{
              'highlightOrderId': order.id,
            },
          );
        },
        onReject: () {
          Navigator.of(ctx).pop();
        },
      ),
    )
        .then((_) => _log('alert dialog closed'))
        .catchError((e, st) {
          _log('showDialog failed: $e');
          FlutterError.reportError(
            FlutterErrorDetails(exception: e, stack: st as StackTrace?),
          );
        })
        .whenComplete(() {
          _isShowingAlert = false;
        });
  }

  Future<void> _playAlertSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/alert.mp3'));
      _log('played alert sound assets/sounds/alert.mp3');
    } catch (e, st) {
      _log('failed to play alert sound: $e');
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: st as StackTrace?),
      );
    }
  }

  OrderEntity _mapAlertToOrderEntity(String key, Map<String, dynamic> data) {
    final createdAtStr = data['created_at'] as String?;
    DateTime createdAt;
    try {
      createdAt = createdAtStr != null
          ? DateTime.parse(createdAtStr).toLocal()
          : DateTime.now();
    } catch (_) {
      createdAt = DateTime.now();
    }

    final totalAmount = (data['total_amount'] as num?)?.toDouble() ?? 0.0;
    final customerName = (data['customer_name'] as String?) ?? 'New customer';
    final displayId = (data['display_id'] as String?) ?? key;

    final placedFrom = (data['placed_from'] as String?) ?? '';
    final upperSource = placedFrom.toUpperCase();
    final channel = switch (upperSource) {
      'UBEREATS' => OrderChannel.ubereats,
      'DOORDASH' => OrderChannel.doordash,
      'MENULOG' => OrderChannel.menulog,
      'WEBSITE' => OrderChannel.website,
      'APP' => OrderChannel.app,
      'QR' => OrderChannel.qr,
      _ => OrderChannel.app,
    };

    // Treat online alerts as delivery orders by default so time is visible.
    final orderType = OrderType.delivery;

    // Minimal synthetic line so the alert has something under "ITEMS".
    final items = <OrderItemEntity>[
      OrderItemEntity(
        name: 'New online order',
        quantity: 1,
        price: totalAmount,
      ),
    ];

    return OrderEntity(
      id: (data['order_uuid'] as String?) ?? key,
      queueNumber: displayId,
      channel: channel,
      orderType: orderType,
      paymentStatus: PaymentStatus.unpaid,
      status: OrderStatus.active,
      paymentMethod: null,
      customerName: customerName,
      customerPhone: null,
      items: items,
      subtotal: totalAmount,
      tax: 0,
      total: totalAmount,
      createdAt: createdAt,
      estimatedTime: createdAt.add(const Duration(minutes: 30)),
      specialInstructions: null,
      tableNumber: null,
      displayStatus: 'NEW',
    );
  }

  @override
  void dispose() {
    _log('disposing (ref="$_refPath")');
    _alertsSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

