import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/usuario_carteira.dart';

class CarteiraState {
  final bool isLoading;
  final UsuarioCarteira? data;
  final String? errorMessage;
  final bool isOffline;

  CarteiraState({
    this.isLoading = false,
    this.data,
    this.errorMessage,
    this.isOffline = false,
  });

  CarteiraState copyWith({
    bool? isLoading,
    UsuarioCarteira? data,
    String? errorMessage,
    bool? isOffline,
  }) {
    return CarteiraState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      errorMessage: errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class CarteiraNotifier extends Notifier<CarteiraState> {
  static const _cacheKey = 'carteira_cache_data';
  static const _cacheUsernameKey = 'carteira_cache_username';
  static const _assinaturaPgjBlackUrl =
      'https://mobile-api.mppb.mp.br/assinatura/assinaturapgj_black.png';
  static const _assinaturaPgjWhiteUrl =
      'https://mobile-api.mppb.mp.br/assinatura/assinaturapgj_white.png';

  @override
  CarteiraState build() {
    Future.microtask(() => fetchCarteira());
    return CarteiraState();
  }

  Future<void> fetchCarteira() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (!ref.mounted) return;
    final dio = ref.read(dioProvider);
    final secureStorage = ref.read(secureStorageProvider);

    try {
      final token = await secureStorage.read(key: 'auth_token');
      final username = await secureStorage.read(key: 'auth_username');
      if (!ref.mounted) return;
      if (token == null || token.trim().isEmpty) {
        await _loadFromCache('Não foi possível carregar a carteira funcional.');
        return;
      }

      // 1. Tentar buscar da API (Online) passando o token via Query Parameter
      final response = await dio.get(
        '/carteiras-funcionais/dados',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (!ref.mounted) return;
      final currentToken = await secureStorage.read(key: 'auth_token');
      if (currentToken == null || currentToken != token) {
        return;
      }

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        final fotoCacheVersion = DateTime.now().microsecondsSinceEpoch;

        // A versão evita cache cruzado sem expor login ou token na URL.
        responseData['foto'] =
            '${dio.options.baseUrl}/carteiras-funcionais/foto?v=$fotoCacheVersion';
        responseData['assinaturaPgjBlackUrl'] = _assinaturaPgjBlackUrl;
        responseData['assinaturaPgjWhiteUrl'] = _assinaturaPgjWhiteUrl;

        final carteira = UsuarioCarteira.fromJson(responseData);

        // 2. Salvar no cache seguro para uso offline
        await secureStorage.write(
          key: _cacheKey,
          value: jsonEncode(carteira.toJson()),
        );
        if (username != null && username.trim().isNotEmpty) {
          await secureStorage.write(key: _cacheUsernameKey, value: username);
        }

        if (!ref.mounted) return;
        state = CarteiraState(
          isLoading: false,
          data: carteira,
          isOffline: false,
        );
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      if (!ref.mounted) return;
      // Se for erro de rede ou timeout, tentar buscar do cache offline
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown ||
          e.type == DioExceptionType.connectionError) {
        await _loadFromCache('Sem conexão. Exibindo dados salvos offline.');
      } else {
        await _loadFromCache(_mensagemErroCarteira(e.response?.statusCode));
      }
    } catch (e) {
      if (!ref.mounted) return;
      // Erro genérico
      await _loadFromCache('Não foi possível carregar a carteira funcional.');
    }
  }

  Future<void> _loadFromCache(String fallbackMessage) async {
    if (!ref.mounted) return;
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final currentUsername = await secureStorage.read(key: 'auth_username');
      final cachedUsername = await secureStorage.read(key: _cacheUsernameKey);
      final cachedStr = await secureStorage.read(key: _cacheKey);

      if (!ref.mounted) return;

      if (currentUsername != null &&
          cachedUsername != null &&
          currentUsername != cachedUsername) {
        await secureStorage.delete(key: _cacheKey);
        await secureStorage.delete(key: _cacheUsernameKey);
        if (!ref.mounted) return;
        state = CarteiraState(isLoading: false, errorMessage: fallbackMessage);
        return;
      }

      if (cachedStr != null && cachedStr.isNotEmpty) {
        final carteira = UsuarioCarteira.fromJson(jsonDecode(cachedStr));
        if (!ref.mounted) return;
        state = CarteiraState(
          isLoading: false,
          data: carteira,
          isOffline: true,
        );
      } else {
        if (!ref.mounted) return;
        state = state.copyWith(isLoading: false, errorMessage: fallbackMessage);
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Você está offline e ocorreu um erro ao ler os dados salvos.',
      );
    }
  }

  String _mensagemErroCarteira(int? statusCode) {
    if (statusCode == 401) {
      return 'Sessão expirada. Faça login novamente.';
    }
    if (statusCode == 404) {
      return 'Carteira funcional não encontrada.';
    }
    return 'Não foi possível carregar a carteira funcional.';
  }
}

final carteiraProvider = NotifierProvider<CarteiraNotifier, CarteiraState>(() {
  return CarteiraNotifier();
});
