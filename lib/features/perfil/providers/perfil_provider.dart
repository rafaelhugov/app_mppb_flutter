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
        if (next.token == null) {
          state = const PerfilState();
        } else {
          Future.microtask(() => carregar(forceRefresh: true));
        }
      }
    });
    Future.microtask(carregar);
    return const PerfilState(isLoading: true);
  }

  Future<void> carregar({bool forceRefresh = false}) async {
    await _carregarEstadoBiometria();
    if (!ref.mounted) return;

    final token = await _tokenAtual();
    if (!ref.mounted) return;
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
      if (!ref.mounted) return;
      final currentToken = await _tokenAtual();
      if (currentToken == null || currentToken != token) return;
      await _salvarCache(perfil);
      if (!ref.mounted) return;
      state = state.copyWith(
        data: perfil,
        isLoading: false,
        isRefreshing: false,
        errorMessage: null,
      );
    } on DioException {
      if (!ref.mounted) return;
      await _loadFromCache('Não foi possível atualizar seu perfil.');
    } catch (_) {
      if (!ref.mounted) return;
      await _loadFromCache('Não foi possível carregar seu perfil.');
    }
  }

  Future<void> refreshBiometrics() => _carregarEstadoBiometria();

  Future<void> _carregarEstadoBiometria() async {
    if (!ref.mounted) return;
    final storage = ref.read(secureStorageProvider);
    final enabled = await storage.read(key: 'biometrics_enabled');
    final credential = await storage.read(key: 'biometric_device_credential');
    final savedPassword = await storage.read(key: 'saved_password');
    if (!ref.mounted) return;
    if (savedPassword != null) {
      await storage.delete(key: 'saved_password');
      await storage.delete(key: 'saved_username');
      await storage.delete(key: 'biometrics_enabled');
      await storage.write(key: 'biometrics_asked', value: 'true');
      await storage.delete(key: biometricPromptStorageKey);
    }
    if (!ref.mounted) return;
    state = state.copyWith(
      biometricsEnabled:
          savedPassword == null &&
          enabled == 'true' &&
          credential?.isNotEmpty == true,
      canUseBiometrics: credential?.isNotEmpty == true,
    );
  }

  Future<void> _salvarCache(PerfilUsuario perfil) async {
    if (!ref.mounted) return;
    final storage = ref.read(secureStorageProvider);
    final username = await storage.read(key: 'auth_username');
    if (!ref.mounted) return;
    await storage.write(key: _cacheKey, value: jsonEncode(perfil.toJson()));
    if (username != null && username.trim().isNotEmpty) {
      if (!ref.mounted) return;
      await storage.write(key: _cacheUsernameKey, value: username);
    }
  }

  Future<void> _loadFromCache(String fallbackMessage) async {
    if (!ref.mounted) return;
    try {
      final storage = ref.read(secureStorageProvider);
      final currentUsername = await storage.read(key: 'auth_username');
      final cachedUsername = await storage.read(key: _cacheUsernameKey);
      final cachedStr = await storage.read(key: _cacheKey);
      if (!ref.mounted) return;

      if (currentUsername != null &&
          cachedUsername != null &&
          currentUsername != cachedUsername) {
        await storage.delete(key: _cacheKey);
        await storage.delete(key: _cacheUsernameKey);
        if (!ref.mounted) return;
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

    if (!ref.mounted) return;
    state = state.copyWith(
      isLoading: false,
      isRefreshing: false,
      errorMessage: fallbackMessage,
    );
  }

  Future<String?> _tokenAtual() async {
    for (var attempt = 0; attempt < 6; attempt++) {
      if (!ref.mounted) return null;
      final stateToken = ref.read(authProvider).token;
      if (stateToken != null && stateToken.trim().isNotEmpty) {
        return stateToken;
      }

      final storedToken = await ref
          .read(secureStorageProvider)
          .read(key: 'auth_token');
      if (!ref.mounted) return null;
      if (storedToken != null && storedToken.trim().isNotEmpty) {
        return storedToken;
      }

      if (attempt < 5) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
    }

    return null;
  }
}

final perfilProvider = NotifierProvider<PerfilNotifier, PerfilState>(() {
  return PerfilNotifier();
});
