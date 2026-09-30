import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/pagamento_model.dart';

class PagamentosState {
  final bool isLoading;
  final String? errorMessage;
  final PagamentoResponse? dados;
  final int exercicioAtual;
  final List<int> anosDisponiveis;
  final bool isLoadingAnos;

  PagamentosState({
    this.isLoading = false,
    this.errorMessage,
    this.dados,
    required this.exercicioAtual,
    this.anosDisponiveis = const [],
    this.isLoadingAnos = false,
  });

  PagamentosState copyWith({
    bool? isLoading,
    String? errorMessage,
    PagamentoResponse? dados,
    int? exercicioAtual,
    List<int>? anosDisponiveis,
    bool? isLoadingAnos,
    bool limparDados = false,
  }) {
    return PagamentosState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Notice: we allow null explicitly
      dados: limparDados ? null : dados ?? this.dados,
      exercicioAtual: exercicioAtual ?? this.exercicioAtual,
      anosDisponiveis: anosDisponiveis ?? this.anosDisponiveis,
      isLoadingAnos: isLoadingAnos ?? this.isLoadingAnos,
    );
  }
}

class PagamentosNotifier extends Notifier<PagamentosState> {
  @override
  PagamentosState build() {
    Future.microtask(() => fetchAnosDisponiveis());
    return PagamentosState(
      exercicioAtual: DateTime.now().year,
      isLoadingAnos: true,
    );
  }

  Future<void> fetchAnosDisponiveis() async {
    state = state.copyWith(isLoadingAnos: true, errorMessage: null);

    try {
      final dio = ref.read(dioProvider);
      final secureStorage = ref.read(secureStorageProvider);
      final token = await secureStorage.read(key: 'auth_token');

      final response = await dio.get(
        '/pagamentos/exercicios',
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      if (response.statusCode == 200) {
        if (!ref.mounted) return;
        final List<dynamic> list = response.data;
        final anos = list.map((e) => e as int).toList();

        if (anos.isEmpty) {
          state = state.copyWith(
            isLoadingAnos: false,
            anosDisponiveis: [],
            limparDados: true,
          );
        } else {
          final anoSelecionado = anos.contains(state.exercicioAtual)
              ? state.exercicioAtual
              : anos.first;
          state = state.copyWith(
            isLoadingAnos: false,
            anosDisponiveis: anos,
            exercicioAtual: anoSelecionado,
          );
          fetchPagamentos(); // Busca do ano recém selecionado
        }
      } else {
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoadingAnos: false,
          errorMessage: 'Erro ao carregar anos disponíveis',
        );
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoadingAnos: false,
        errorMessage: 'Falha ao buscar exercícios. Verifique a internet.',
      );
    }
  }

  Future<void> fetchPagamentos() async {
    final exercicioRequisitado = state.exercicioAtual;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final dio = ref.read(dioProvider);
      final secureStorage = ref.read(secureStorageProvider);
      final token = await secureStorage.read(key: 'auth_token');

      final response = await dio.get(
        '/pagamentos/$exercicioRequisitado',
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      if (!ref.mounted || state.exercicioAtual != exercicioRequisitado) {
        return;
      }

      if (response.statusCode == 204) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          limparDados: true,
        );
        return;
      }

      if (response.data != null) {
        final PagamentoResponse res = PagamentoResponse.fromJson(response.data);
        // Using explicit instantiation to clear previous error
        state = PagamentosState(
          isLoading: false,
          dados: res,
          exercicioAtual: state.exercicioAtual,
          anosDisponiveis: state.anosDisponiveis,
          isLoadingAnos: state.isLoadingAnos,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar dados de pagamentos',
        );
      }
    } on DioException catch (e) {
      String msg = 'Falha de conexão. Verifique sua internet.';
      if (e.response != null) {
        if (e.response?.statusCode == 404) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: null,
            limparDados: true,
          ); // Tratar 404 como empty
          return;
        }
        msg = 'Erro no servidor: ${e.response?.statusCode}';
      }
      state = PagamentosState(
        isLoading: false,
        exercicioAtual: state.exercicioAtual,
        errorMessage: msg,
        dados: state.dados,
        anosDisponiveis: state.anosDisponiveis,
        isLoadingAnos: state.isLoadingAnos,
      );
    } catch (e) {
      state = PagamentosState(
        isLoading: false,
        exercicioAtual: state.exercicioAtual,
        errorMessage: 'Erro inesperado: $e',
        dados: state.dados,
        anosDisponiveis: state.anosDisponiveis,
        isLoadingAnos: state.isLoadingAnos,
      );
    }
  }

  void mudarExercicio(int delta) {
    if (state.anosDisponiveis.isEmpty) return;
    final currentIndex = state.anosDisponiveis.indexOf(state.exercicioAtual);
    if (currentIndex == -1) return;

    // O array deve estar ordenado descrescente, então "voltar no tempo" (delta -1) significa ir para um índice MAIOR.
    // "Avançar no tempo" (delta +1) significa ir para um índice MENOR.
    final novoIndex = currentIndex - delta;

    if (novoIndex >= 0 && novoIndex < state.anosDisponiveis.length) {
      state = state.copyWith(exercicioAtual: state.anosDisponiveis[novoIndex]);
      fetchPagamentos();
    }
  }

  void selecionarExercicio(int ano) {
    if (state.anosDisponiveis.contains(ano)) {
      state = state.copyWith(exercicioAtual: ano);
      fetchPagamentos();
    }
  }
}

final pagamentosProvider =
    NotifierProvider<PagamentosNotifier, PagamentosState>(() {
      return PagamentosNotifier();
    });
