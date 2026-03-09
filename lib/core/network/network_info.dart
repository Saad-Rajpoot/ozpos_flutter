import 'package:connectivity_plus/connectivity_plus.dart';

/// Network information interface
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Network information implementation
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  bool? _overrideIsConnected;

  NetworkInfoImpl({required Connectivity connectivity})
      : _connectivity = connectivity;

  @override
  Future<bool> get isConnected async {
    if (_overrideIsConnected != null) {
      return _overrideIsConnected!;
    }
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Allows tests/debug UI to override connectivity perception without
  /// touching the underlying OS/network.
  ///
  /// Pass `true` to force "online", `false` to force "offline", or `null`
  /// to restore real connectivity checks.
  void setOverrideIsConnected(bool? value) {
    _overrideIsConnected = value;
  }

  /// Exposes the current override value for debug UI.
  /// `null` means no override is active.
  bool? get overrideIsConnected => _overrideIsConnected;
}
