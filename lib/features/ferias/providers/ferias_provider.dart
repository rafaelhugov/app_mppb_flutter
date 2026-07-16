import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/solicitacao_ferias.dart';

class FeriasState {
  final bool isLoading;
  final String? errorMessage;
  final List<SolicitacaoFerias> solicitacoes;

  FeriasState({
    this.isLoading = false,
    this.errorMessage,
    this.solicitacoes = const [],
  });

  FeriasState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<SolicitacaoFerias>? solicitacoes,
  }) {
    return FeriasState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      solicitacoes: solicitacoes ?? this.solicitacoes,
    );
  }
}

class FeriasNotifier extends Notifier<FeriasState> {
  @override
  FeriasState build() {
    Future.microtask(() => fetchSolicitacoes());
    return FeriasState();
  }

  Future<void> fetchSolicitacoes() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final dio = ref.read(dioProvider);
      final secureStorage = ref.read(secureStorageProvider);
      final token = await secureStorage.read(key: 'auth_token');

      final response = await dio.get(
        '/ferias/minhas-solicitacoes',
        queryParameters: token != null ? {'token': token} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final solicitacoes = data.map((json) => SolicitacaoFerias.fromJson(json)).toList();
        state = state.copyWith(isLoading: false, solicitacoes: solicitacoes);
      } else if (response.statusCode == 204) {
        state = state.copyWith(isLoading: false, solicitacoes: []);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar solicitações. Tente novamente.',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        state = state.copyWith(isLoading: false, errorMessage: 'Sessão expirada. Faça login novamente.');
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Falha de conexão. Verifique sua internet.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro inesperado.');
    }
  }

  Future<bool> novaSolicitacao(Map<String, dynamic> data) async {
    try {
      final dio = ref.read(dioProvider);
      final secureStorage = ref.read(secureStorageProvider);
      final token = await secureStorage.read(key: 'auth_token');

      final response = await dio.post(
        '/ferias/solicitar',
        data: data,
        queryParameters: token != null ? {'token': token} : null,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchSolicitacoes();
        return true;
      }
    } catch (e) {
      // Tratar erro
    }
    return false;
  }
}

final feriasProvider = NotifierProvider<FeriasNotifier, FeriasState>(() {
  return FeriasNotifier();
});
