/// High-level connectivity status for the app.
///
/// This models the 3-layer connectivity state described in the
/// offline-first blueprint:
/// 1. Transport (Wi-Fi/mobile) availability
/// 2. General internet reachability
/// 3. POS API health reachability
enum ConnectivityStatus {
  /// No network transport is available (offline at OS level).
  noTransport,

  /// Transport exists, but we cannot reach the broader internet.
  noInternet,

  /// Internet is reachable, but the POS API health endpoint is unavailable.
  apiDown,

  /// Internet is reachable and the POS API health endpoint reports "online".
  online,
}

/// Snapshot of current connectivity, with optional sync overlay.
class ConnectivitySnapshot {
  const ConnectivitySnapshot({
    required this.status,
    this.isSyncing = false,
    this.lastCheckedAt,
  });

  final ConnectivityStatus status;
  final bool isSyncing;
  final DateTime? lastCheckedAt;

  ConnectivitySnapshot copyWith({
    ConnectivityStatus? status,
    bool? isSyncing,
    DateTime? lastCheckedAt,
  }) {
    return ConnectivitySnapshot(
      status: status ?? this.status,
      isSyncing: isSyncing ?? this.isSyncing,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }
}

