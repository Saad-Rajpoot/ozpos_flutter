import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import 'api_client.dart';
import 'connectivity_state.dart';

/// Connectivity service implementing a 3-layer connectivity model:
/// 1) Transport availability (Wi-Fi/mobile via connectivity_plus)
/// 2) Internet reachability (DNS/HTTP probe)
/// 3) POS API health endpoint reachability
class ConnectivityService {
  ConnectivityService({
    required Connectivity connectivity,
    required ApiClient apiClient,
    Duration? offlinePollInterval,
    Duration? healthTimeout,
  })  : _connectivity = connectivity,
        _apiClient = apiClient,
        _offlinePollInterval =
            offlinePollInterval ?? AppConstants.offlineRecheckInterval,
        _healthTimeout = healthTimeout ?? const Duration(seconds: 5) {
    _current = const ConnectivitySnapshot(
      status: ConnectivityStatus.noTransport,
      lastCheckedAt: null,
    );
  }

  final Connectivity _connectivity;
  final ApiClient _apiClient;
  final Duration _offlinePollInterval;
  final Duration _healthTimeout;

  final _controller =
      StreamController<ConnectivitySnapshot>.broadcast(sync: true);
  StreamSubscription<ConnectivityResult>? _connectivitySub;
  Timer? _offlineTimer;
  bool _isChecking = false;

  late ConnectivitySnapshot _current;

  /// Current connectivity snapshot.
  ConnectivitySnapshot get current => _current;

  /// Stream of connectivity snapshots.
  Stream<ConnectivitySnapshot> get stream => _controller.stream;

  /// Start monitoring connectivity.
  void start() {
    // Initial check
    _scheduleCheck();

    // Listen for transport changes
    _connectivitySub ??=
        _connectivity.onConnectivityChanged.listen((_) => _scheduleCheck());
  }

  /// Stop monitoring and clean up resources.
  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    _offlineTimer?.cancel();
    _offlineTimer = null;
    await _controller.close();
  }

  void _scheduleCheck() {
    if (_isChecking) return;
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final snapshot = await _computeSnapshot();
      _updateSnapshot(snapshot);
    } finally {
      _isChecking = false;
    }
  }

  Future<ConnectivitySnapshot> _computeSnapshot() async {
    // Layer 1: transport
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      return _offlineSnapshot(ConnectivityStatus.noTransport);
    }

    // Layer 2: internet reachability (DNS lookup)
    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      return _offlineSnapshot(ConnectivityStatus.noInternet);
    }

    // Layer 3: POS API health
    final apiOnline = await _isApiHealthy();
    if (!apiOnline) {
      return _offlineSnapshot(ConnectivityStatus.apiDown);
    }

    return ConnectivitySnapshot(
      status: ConnectivityStatus.online,
      isSyncing: _current.isSyncing,
      lastCheckedAt: DateTime.now(),
    );
  }

  ConnectivitySnapshot _offlineSnapshot(ConnectivityStatus status) {
    return ConnectivitySnapshot(
      status: status,
      isSyncing: _current.isSyncing,
      lastCheckedAt: DateTime.now(),
    );
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com')
          .timeout(_healthTimeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  Future<bool> _isApiHealthy() async {
    try {
      final response = await _apiClient.get(
        AppConstants.healthEndpoint,
        options: Options(
          sendTimeout: _healthTimeout,
          receiveTimeout: _healthTimeout,
          // connectTimeout is applied at client level; we keep this lightweight.
        ),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) return false;

      final success = data['success'] == true;
      final status = (data['data'] as Map?)?['status'] as String?;

      return success && status == 'online';
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ConnectivityService: health check failed: $e');
      }
      return false;
    }
  }

  void _updateSnapshot(ConnectivitySnapshot next) {
    if (_current.status == next.status &&
        _current.isSyncing == next.isSyncing) {
      _current = next;
      return;
    }

    _current = next;
    if (!_controller.isClosed) {
      _controller.add(_current);
    }

    // Manage offline polling loop.
    if (_current.status == ConnectivityStatus.online) {
      _stopOfflinePolling();
    } else {
      _startOfflinePolling();
    }
  }

  void _startOfflinePolling() {
    _offlineTimer ??= Timer.periodic(_offlinePollInterval, (_) {
      _scheduleCheck();
    });
  }

  void _stopOfflinePolling() {
    _offlineTimer?.cancel();
    _offlineTimer = null;
  }

  /// Mark that a sync operation is running; this will be reflected
  /// in the snapshot but does not affect connectivity decisions.
  void setSyncing(bool isSyncing) {
    _updateSnapshot(_current.copyWith(isSyncing: isSyncing));
  }
}

