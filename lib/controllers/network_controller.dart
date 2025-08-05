import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkManager extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  var isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      _updateConnectionStatus(result);
    });
  }

  Future<void> _checkInitialConnection() async {
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    bool connected = result != ConnectivityResult.none;

    isConnected.value = connected;
  }

  void retryConnection() async {
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _updateConnectionStatus(result);
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
