import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/perfil_usuario.dart';
import '../repositories/perfil_repository.dart';

class PerfilState {
  final PerfilUsuario? data;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final bool biometricsEnabled;
  final bool canUseBiometrics;

  const PerfilState({
    this.data,
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.biometricsEnabled = false,
    this.canUseBiometrics = false,
  });

  PerfilState copyWith({
    PerfilUsuario? data,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool? biometricsEnabled,
    bool? canUseBiometrics,
  }) {
    return PerfilState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      canUseBiometrics: canUseBiometrics ?? this.canUseBiometrics,
    );
  }
}

class PerfilNotifier extends Notifier<PerfilState> {
  static const _cacheKey = 'perfil_cache_data';
  static const _cacheUsernameKey = 'perfil_cache_username';

  String? _ultimoToken;

  @override
  PerfilState build() {
    ref.listen(authProvider, (previous, next) {
      if (previous?.token != next.token) {
        _ultimoToken = next.token;
        Future.microtask(() => carregar(forceRefresh: true));
      }
    });
    Future.microtask(carregar);
    return const PerfilState(isLoading: true);
  }

  Future<void> carregar({bool forceRefresh = false}) async {
    await _carregarEstadoBiometria();

    final token = await _tokenAtual();
    if (token == null) {
      await _loadFromCache('Não foi possível carregar seu perfil.');
      return;
    }

    if (!forceRefresh && _ultimoToken == token && state.data != null) {
      return;
    }
    _ultimoToken = token;

    state = state.copyWith(
      isLoading: state.data == null,
      isRefreshing: state.data != null,
      errorMessage: null,
    );

    try {
      final perfil = await ref
          .read(perfilRepositoryProvider)
          .buscarPerfil(token: token);
      await _salvarCache(perfil);
      state = state.copyWith(
        data: perfil,
        isLoading: false,
        isRefreshing: false,
        errorMessage: null,
      );
    } on DioException {
      await _loadFromCache('Não foi possível atualizar seu perfil.');
    } catch (_) {
      await _loadFromCache('Não foi possível carregar seu perfil.');
    }
  }

  Future<void> refreshBiometrics() => _carregarEstadoBiometria();

  Future<void> _carregarEstadoBiometria() async {
    final storage = ref.read(secureStorageProvider);
    final enabled = await storage.read(key: 'biometrics_enabled');
    final savedPassword = await storage.read(key: 'saved_password');
    if (savedPassword != null) {
      await storage.delete(key: 'saved_password');
      await storage.delete(key: 'saved_username');
      await storage.delete(key: 'biometrics_enabled');
      await storage.write(key: 'biometrics_asked', value: 'true');
    }
    state = state.copyWith(
      biometricsEnabled: savedPassword == null && enabled == 'true' && false,
      canUseBiometrics: false,
    );
  }

  Future<void> _salvarCache(PerfilUsuario perfil) async {
    final storage = ref.read(secureStorageProvider);
    final username = await storage.read(key: 'auth_username');
    await storage.write(key: _cacheKey, value: jsonEncode(perfil.toJson()));
    if (username != null && username.trim().isNotEmpty) {
      await storage.write(key: _cacheUsernameKey, value: username);
    }
  }

  Future<void> _loadFromCache(String fallbackMessage) async {
    try {
      final storage = ref.read(secureStorageProvider);
      final currentUsername = await storage.read(key: 'auth_username');
      final cachedUsername = await storage.read(key: _cacheUsernameKey);
      final cachedStr = await storage.read(key: _cacheKey);

      if (currentUsername != null &&
          cachedUsername != null &&
          currentUsername != cachedUsername) {
        await storage.delete(key: _cacheKey);
        await storage.delete(key: _cacheUsernameKey);
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: fallbackMessage,
        );
        return;
      }

      if (cachedStr != null && cachedStr.isNotEmpty) {
        state = state.copyWith(
          data: PerfilUsuario.fromJson(jsonDecode(cachedStr)),
          isLoading: false,
          isRefreshing: false,
          errorMessage: fallbackMessage,
        );
        return;
      }
    } catch (_) {
      // Mantem a mensagem padrao abaixo.
    }

    state = state.copyWith(
      isLoading: false,
      isRefreshing: false,
      errorMessage: fallbackMessage,
    );
  }

  Future<String?> _tokenAtual() async {
    for (var attempt = 0; attempt < 6; attempt++) {
      final stateToken = ref.read(authProvider).token;
      if (stateToken != null && stateToken.trim().isNotEmpty) {
        return stateToken;
      }

      final storedToken = await ref
          .read(secureStorageProvider)
          .read(key: 'auth_token');
      if (storedToken != null && storedToken.trim().isNotEmpty) {
        return storedToken;
      }

      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    return null;
  }
}

final perfilProvider = NotifierProvider<PerfilNotifier, PerfilState>(() {
  return PerfilNotifier();
});
