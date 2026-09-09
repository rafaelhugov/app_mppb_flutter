import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityNotifier extends Notifier<bool> {
  static const _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://aplicativo-api.mppb.mp.br',
  );

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _offlineRetryTimer;
  int _checkGeneration = 0;

  @override
  bool build() {
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    ref.onDispose(() {
      _subscription?.cancel();
      _offlineRetryTimer?.cancel();
    });
    return true;
  }

  Future<void> _initConnectivity() async {
    try {
      await refresh();
    } catch (e) {
      await refresh();
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    await refresh(connectivityResult: result);
  }

  Future<void> refresh({List<ConnectivityResult>? connectivityResult}) async {
    final currentCheck = ++_checkGeneration;
    final result = connectivityResult ?? await _connectivity.checkConnectivity();
    final hasNetwork = result.any((item) => item != ConnectivityResult.none);
    final hasInternet = hasNetwork && await _hasInternetAccess();
    if (currentCheck == _checkGeneration) {
      state = hasInternet;
      _syncOfflineRetry();
    }
  }

  void _syncOfflineRetry() {
    if (state) {
      _offlineRetryTimer?.cancel();
      _offlineRetryTimer = null;
      return;
    }

    _offlineRetryTimer ??= Timer.periodic(const Duration(seconds: 20), (_) {
      refresh();
    });
  }

  Future<bool> _hasInternetAccess() async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ),
    );
    Uri? probeUri;

    try {
      final baseUri = Uri.parse(_apiUrl);
      probeUri = baseUri.replace(path: '/api/public/noticias');
      
      final response = await dio.get(probeUri.toString());
      return response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 500;
    } catch (e) {
      debugPrint('=== CONNECTIVITY_PROVIDER ERROR ===');
      debugPrint('Tried URL: ${probeUri ?? _apiUrl}');
      debugPrint('Error: $e');
      return false;
    } finally {
      dio.close(force: true);
    }
  }
}

// Retorna true se estiver online, false se estiver offline
final connectivityProvider = NotifierProvider<ConnectivityNotifier, bool>(() {
  return ConnectivityNotifier();
});
