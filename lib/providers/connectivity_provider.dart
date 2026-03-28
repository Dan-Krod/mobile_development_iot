import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _init();
  }

  void _init() {
    Connectivity().checkConnectivity().then(_updateStatus);

    Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final isConnected =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    if (_isOnline != isConnected) {
      _isOnline = isConnected;
      debugPrint('🌐 МЕРЕЖА: ${_isOnline ? "ОНЛАЙН" : "ОФЛАЙН"}');
      notifyListeners();
    }
  }
}
