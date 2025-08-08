import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  void startMonitoring(Function onConnected) async {
    // Initial check
    final List<ConnectivityResult> status = await _connectivity
        .checkConnectivity();
    if (_isConnected(status)) {
      onConnected();
    }

    // Listen for changes
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (_isConnected(results)) {
        onConnected();
      }
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }
}
