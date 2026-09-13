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
  static const _probePath = '/api/public/health';

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
    final result =
        connectivityResult ?? await _connectivity.checkConnectivity();
    final hasNetwork = await _hasNetworkConnection(result);
    final hasInternet = hasNetwork && await _hasInternetAccessWithRetry();
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

  Future<bool> _hasNetworkConnection(List<ConnectivityResult> initial) async {
    if (_containsNetwork(initial)) {
      return true;
    }

    for (final delay in const [
      Duration(milliseconds: 500),
      Duration(milliseconds: 900),
    ]) {
      await Future<void>.delayed(delay);
      final result = await _connectivity.checkConnectivity();
      if (_containsNetwork(result)) {
        return true;
      }
    }

    return false;
  }

  bool _containsNetwork(List<ConnectivityResult> result) {
    return result.any((item) => item != ConnectivityResult.none);
  }

  Future<bool> _hasInternetAccessWithRetry() async {
    const attempts = 3;
    for (var attempt = 0; attempt < attempts; attempt++) {
      if (await _hasInternetAccess()) {
        return true;
      }
      if (attempt < attempts - 1) {
        await Future<void>.delayed(Duration(milliseconds: 450 * (attempt + 1)));
      }
    }
    return false;
  }

  Future<bool> _hasInternetAccess() async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    Uri? probeUri;

    try {
      final baseUri = Uri.parse(_apiUrl);
      probeUri = baseUri.replace(path: _probePath, query: null);

      final response = await dio.get(probeUri.toString());
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 500;
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
