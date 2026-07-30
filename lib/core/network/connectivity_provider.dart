import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityNotifier extends Notifier<bool> {
  static const _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://aplicativo-api.mppb.mp.br',
  );

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  int _checkGeneration = 0;

  @override
  bool build() {
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    ref.onDispose(() => _subscription?.cancel());
    return true;
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      state = await _hasInternetAccess();
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    final currentCheck = ++_checkGeneration;
    final hasInternet = await _hasInternetAccess();
    if (currentCheck == _checkGeneration) {
      state = hasInternet;
    }
  }

  Future<bool> _hasInternetAccess() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);

    try {
      final baseUri = Uri.parse(_apiUrl);
      final probeUri = baseUri.replace(path: '/api/public/noticias');
      final request = await client
          .getUrl(probeUri)
          .timeout(const Duration(seconds: 4));
      final response = await request.close().timeout(
        const Duration(seconds: 4),
      );
      await response.drain<void>();
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      return false;
    } finally {
      client.close(force: true);
    }
  }
}

// Retorna true se estiver online, false se estiver offline
final connectivityProvider = NotifierProvider<ConnectivityNotifier, bool>(() {
  return ConnectivityNotifier();
});
