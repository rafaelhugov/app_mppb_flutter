import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/push_notification_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/preferencias_notificacao.dart';
import '../repositories/preferencias_notificacao_repository.dart';

class PreferenciasNotificacaoState {
  final PreferenciasNotificacao preferencias;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const PreferenciasNotificacaoState({
    this.preferencias = const PreferenciasNotificacao(),
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  PreferenciasNotificacaoState copyWith({
    PreferenciasNotificacao? preferencias,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return PreferenciasNotificacaoState(
      preferencias: preferencias ?? this.preferencias,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class PreferenciasNotificacaoNotifier
    extends Notifier<PreferenciasNotificacaoState> {
  static const _cacheKey = 'preferencias_notificacao_cache';

  @override
  PreferenciasNotificacaoState build() {
    ref.listen(authProvider, (previous, next) {
      if (previous?.token == next.token) return;
      if (next.token == null) {
        state = const PreferenciasNotificacaoState();
      } else {
        Future.microtask(carregar);
      }
    });
    Future.microtask(carregar);
    return const PreferenciasNotificacaoState(isLoading: true);
  }

  Future<void> carregar() async {
    final token = await _tokenAtual();
    if (!ref.mounted) return;
    if (token == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final preferencias = await ref
          .read(preferenciasNotificacaoRepositoryProvider)
          .buscar(token: token);
      if (!ref.mounted) return;
      await _salvarCache(preferencias);
      await _sincronizarNoticias(preferencias.pushNoticias);
      if (!ref.mounted) return;
      state = state.copyWith(
        preferencias: preferencias,
        isLoading: false,
        errorMessage: null,
      );
    } on DioException {
      await _carregarCache('Não foi possível atualizar suas preferências.');
    } catch (_) {
      await _carregarCache('Não foi possível carregar suas preferências.');
    }
  }

  Future<bool> atualizar(PreferenciasNotificacao preferencias) async {
    if (state.isSaving) return false;
    final token = await _tokenAtual();
    if (!ref.mounted || token == null) return false;

    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final salvas = await ref
          .read(preferenciasNotificacaoRepositoryProvider)
          .salvar(token: token, preferencias: preferencias);
      if (!ref.mounted) return false;
      await _salvarCache(salvas);
      await _sincronizarNoticias(salvas.pushNoticias);
      if (!ref.mounted) return false;
      state = state.copyWith(
        preferencias: salvas,
        isSaving: false,
        errorMessage: null,
      );
      return true;
    } on DioException catch (error) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: _mensagemErroSalvamento(error),
      );
      return false;
    } catch (_) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Ocorreu uma falha inesperada ao salvar a preferência.',
      );
      return false;
    }
  }

  Future<void> _salvarCache(PreferenciasNotificacao preferencias) async {
    final storage = ref.read(secureStorageProvider);
    final username = await storage.read(key: 'auth_username');
    if (username == null || username.trim().isEmpty) return;
    await storage.write(
      key: _cacheKey,
      value: jsonEncode({
        'username': username,
        'preferencias': preferencias.toJson(),
      }),
    );
  }

  Future<void> _carregarCache(String errorMessage) async {
    if (!ref.mounted) return;
    try {
      final storage = ref.read(secureStorageProvider);
      final username = await storage.read(key: 'auth_username');
      final cached = await storage.read(key: _cacheKey);
      if (cached != null && username != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        if (json['username'] == username) {
          final preferencias = PreferenciasNotificacao.fromJson(
            json['preferencias'] as Map<String, dynamic>,
          );
          await _sincronizarNoticias(preferencias.pushNoticias);
          if (!ref.mounted) return;
          state = state.copyWith(
            preferencias: preferencias,
            isLoading: false,
            errorMessage: errorMessage,
          );
          return;
        }
      }
    } catch (_) {
      // Mantém o padrão seguro e informa que a leitura não pôde ser concluída.
    }
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: false, errorMessage: errorMessage);
  }

  Future<void> _sincronizarNoticias(bool habilitadas) async {
    if (!PushNotificationService.isSupportedPlatform ||
        !PushNotificationService.isFirebaseReady) {
      return;
    }
    try {
      await PushNotificationService.instance.setPublicNewsSubscription(
        habilitadas,
      );
    } catch (_) {
      // O servidor já preserva a escolha; o tópico será sincronizado na próxima carga.
    }
  }

  Future<String?> _tokenAtual() async {
    final stateToken = ref.read(authProvider).token;
    if (stateToken != null && stateToken.trim().isNotEmpty) return stateToken;
    return ref.read(secureStorageProvider).read(key: 'auth_token');
  }

  String _mensagemErroSalvamento(DioException error) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) {
      return 'Sua sessão não foi aceita pelo serviço. Entre novamente e tente salvar.';
    }
    if (status == 404 || status == 405) {
      return 'O serviço de preferências ainda não está disponível nesta versão do servidor.';
    }
    if (status != null && status >= 500) {
      return 'O servidor não conseguiu salvar a preferência. Tente novamente em alguns instantes.';
    }
    if (status != null) {
      return 'O serviço recusou a alteração da preferência (HTTP $status).';
    }
    return 'Não foi possível conectar ao serviço de preferências.';
  }
}

final preferenciasNotificacaoProvider =
    NotifierProvider<
      PreferenciasNotificacaoNotifier,
      PreferenciasNotificacaoState
    >(() => PreferenciasNotificacaoNotifier());
