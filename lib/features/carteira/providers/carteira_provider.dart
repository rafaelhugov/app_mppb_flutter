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

  @override
  CarteiraState build() {
    Future.microtask(() => fetchCarteira());
    return CarteiraState();
  }

  Future<void> fetchCarteira() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final dio = ref.read(dioProvider);
    final secureStorage = ref.read(secureStorageProvider);

    try {
      final token = await secureStorage.read(key: 'auth_token');
      final username = await secureStorage.read(key: 'auth_username');
      if (token == null || token.trim().isEmpty) {
        await _loadFromCache('Não foi possível carregar a carteira funcional.');
        return;
      }

      // 1. Tentar buscar da API (Online) passando o token via Query Parameter
      final response = await dio.get(
        '/carteiras-funcionais/dados',
        queryParameters: {'token': token},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Injetar URL da foto assim como no Vue
        responseData['foto'] =
            '${dio.options.baseUrl}/carteiras-funcionais/foto?token=$token';

        final carteira = UsuarioCarteira.fromJson(responseData);

        // 2. Salvar no cache seguro para uso offline
        await secureStorage.write(
          key: _cacheKey,
          value: jsonEncode(carteira.toJson()),
        );
        if (username != null && username.trim().isNotEmpty) {
          await secureStorage.write(key: _cacheUsernameKey, value: username);
        }

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
      // Erro genérico
      await _loadFromCache('Não foi possível carregar a carteira funcional.');
    }
  }

  Future<void> _loadFromCache(String fallbackMessage) async {
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final currentUsername = await secureStorage.read(key: 'auth_username');
      final cachedUsername = await secureStorage.read(key: _cacheUsernameKey);
      final cachedStr = await secureStorage.read(key: _cacheKey);

      if (currentUsername != null &&
          cachedUsername != null &&
          currentUsername != cachedUsername) {
        await secureStorage.delete(key: _cacheKey);
        await secureStorage.delete(key: _cacheUsernameKey);
        state = CarteiraState(isLoading: false, errorMessage: fallbackMessage);
        return;
      }

      if (cachedStr != null && cachedStr.isNotEmpty) {
        final carteira = UsuarioCarteira.fromJson(jsonDecode(cachedStr));
        state = CarteiraState(
          isLoading: false,
          data: carteira,
          isOffline: true,
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: fallbackMessage);
      }
    } catch (e) {
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
