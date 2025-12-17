import 'package:connectivity_plus/connectivity_plus.dart';

/// Network information interface
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Network information implementation
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl({required Connectivity connectivity})
      : _connectivity = connectivity;

  @override
  Future<bool> get isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
