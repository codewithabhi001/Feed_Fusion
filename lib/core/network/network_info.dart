import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';

/// Reactive network connectivity checker using connectivity_plus.
/// Provides real-time connectivity status and auto-refresh triggers.
class NetworkInfo extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = false.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // Callback invoked when connectivity is restored
  Function? onConnectivityRestored;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      AppLogger.logError('Failed to check connectivity', e);
      isConnected.value = false;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = isConnected.value;

    // Connected if any result is not 'none'
    isConnected.value = results.any((r) => r != ConnectivityResult.none);

    AppLogger.log(
      '🌐 Connectivity: ${isConnected.value ? "ONLINE" : "OFFLINE"}',
    );

    // Trigger silent refresh when connectivity is restored
    if (!wasConnected && isConnected.value) {
      AppLogger.log('🔄 Connectivity restored — triggering silent refresh');
      onConnectivityRestored?.call();
    }
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      isConnected.value = results.any((r) => r != ConnectivityResult.none);
      return isConnected.value;
    } catch (e) {
      return false;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
