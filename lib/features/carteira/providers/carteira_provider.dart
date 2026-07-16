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
      
      // 1. Tentar buscar da API (Online) passando o token via Query Parameter
      final response = await dio.get(
        '/carteiras-funcionais/dados',
        queryParameters: token != null ? {'token': token} : null,
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Injetar URL da foto assim como no Vue
        if (token != null) {
          responseData['foto'] = '${dio.options.baseUrl}/carteiras-funcionais/foto?token=$token';
        }

        final carteira = UsuarioCarteira.fromJson(responseData);
        
        // 2. Salvar no cache seguro para uso offline
        await secureStorage.write(
          key: _cacheKey, 
          value: jsonEncode(carteira.toJson())
        );

        state = state.copyWith(
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
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao buscar dados da carteira: ${e.message}',
        );
      }
    } catch (e) {
      // Erro genérico
      await _loadFromCache('Sem conexão. Exibindo dados salvos offline.');
    }
  }

  Future<void> _loadFromCache(String fallbackMessage) async {
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final cachedStr = await secureStorage.read(key: _cacheKey);
      
      if (cachedStr != null && cachedStr.isNotEmpty) {
        final carteira = UsuarioCarteira.fromJson(jsonDecode(cachedStr));
        state = state.copyWith(
          isLoading: false,
          data: carteira,
          isOffline: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Você está offline e não há dados salvos.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Você está offline e ocorreu um erro ao ler os dados salvos.',
      );
    }
  }
}

final carteiraProvider = NotifierProvider<CarteiraNotifier, CarteiraState>(() {
  return CarteiraNotifier();
});
