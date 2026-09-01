import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/processo.dart';

class ConsultaProcessosState {
  final bool isLoading;
  final bool isLoadingFiltros;
  final List<ProcessoResumo> resultados;
  final ProcessoFiltros? filtros;
  final String? errorMessage;
  final String? filtrosErrorMessage;
  final bool searched;

  ConsultaProcessosState({
    this.isLoading = false,
    this.isLoadingFiltros = false,
    this.resultados = const [],
    this.filtros = const ProcessoFiltros(),
    this.errorMessage,
    this.filtrosErrorMessage,
    this.searched = false,
  });

  ProcessoFiltros get filtrosOrEmpty => filtros ?? const ProcessoFiltros();

  ConsultaProcessosState copyWith({
    bool? isLoading,
    bool? isLoadingFiltros,
    List<ProcessoResumo>? resultados,
    ProcessoFiltros? filtros,
    String? errorMessage,
    String? filtrosErrorMessage,
    bool? searched,
  }) {
    return ConsultaProcessosState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingFiltros: isLoadingFiltros ?? this.isLoadingFiltros,
      resultados: resultados ?? this.resultados,
      filtros: filtros ?? this.filtros,
      errorMessage: errorMessage,
      filtrosErrorMessage: filtrosErrorMessage,
      searched: searched ?? this.searched,
    );
  }
}

class ConsultaProcessosNotifier extends Notifier<ConsultaProcessosState> {
  String _mensagemErroBusca(Object error, Map<String, dynamic> filtros) {
    final pesquisouTipoAtividade =
        filtros['idTipoAtividade']?.toString().trim().isNotEmpty == true;

    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;
      if (statusCode == 400 &&
          responseData is String &&
          responseData.isNotEmpty) {
        return responseData;
      }
      if (statusCode != null && statusCode >= 500) {
        return 'Não foi possível processar a consulta agora. Tente novamente mais tarde.';
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        if (pesquisouTipoAtividade) {
          return 'A consulta por tipo de atividade demorou mais que o esperado. Combine com outro filtro ou tente novamente.';
        }
        return 'Tempo de conexão esgotado. Verifique sua conexão e tente novamente.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Não foi possível conectar ao serviço. Verifique sua conexão.';
      }
    }
    return 'Não foi possível concluir a consulta. Tente novamente.';
  }

  @override
  ConsultaProcessosState build() {
    return ConsultaProcessosState();
  }

  Future<void> carregarFiltros() async {
    if (state.isLoadingFiltros || state.filtrosOrEmpty.comarcas.isNotEmpty) {
      return;
    }

    state = state.copyWith(isLoadingFiltros: true, filtrosErrorMessage: null);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/public/v1/processos/filtros');

      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoadingFiltros: false,
          filtros: ProcessoFiltros.fromJson(response.data),
        );
      } else {
        throw Exception('Status: ${response.statusCode}');
      }
    } catch (_) {
      state = state.copyWith(
        isLoadingFiltros: false,
        filtrosErrorMessage:
            'Não foi possível carregar os filtros. Tente novamente.',
      );
    }
  }

  Future<void> buscarProcessos(Map<String, dynamic> filtros) async {
    state = state.copyWith(isLoading: true, errorMessage: null, searched: true);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/api/public/v1/processos/consulta',
        data: filtros,
        options: Options(receiveTimeout: const Duration(seconds: 45)),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        final list = data.map((item) => ProcessoResumo.fromJson(item)).toList();
        state = state.copyWith(isLoading: false, resultados: list);
      } else {
        throw Exception('Status: ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mensagemErroBusca(e, filtros),
      );
    }
  }

  void limpar() {
    state = ConsultaProcessosState();
  }
}

final consultaProcessosProvider =
    NotifierProvider<ConsultaProcessosNotifier, ConsultaProcessosState>(() {
      return ConsultaProcessosNotifier();
    });

// CAPTCHA Provider
final captchaProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/api/public/v1/captcha');
  if (response.statusCode == 200) {
    return response.data; // { "imageBase64": "...", "token": "..." }
  }
  throw Exception('Falha ao carregar captcha');
});

// DETALHES Provider
class ProcessoDetalheParams {
  final String idProcesso;
  final String captchaToken;
  final String captchaValue;

  ProcessoDetalheParams({
    required this.idProcesso,
    required this.captchaToken,
    required this.captchaValue,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcessoDetalheParams &&
          idProcesso == other.idProcesso &&
          captchaToken == other.captchaToken &&
          captchaValue == other.captchaValue;

  @override
  int get hashCode =>
      idProcesso.hashCode ^ captchaToken.hashCode ^ captchaValue.hashCode;
}

final processoDetalhesProvider = FutureProvider.autoDispose
    .family<ProcessoDetalhe, ProcessoDetalheParams>((ref, params) async {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        '/api/public/v1/processos/${params.idProcesso}/detalhes',
        queryParameters: {
          'captchaToken': params.captchaToken,
          'captchaValue': params.captchaValue,
        },
      );

      if (response.statusCode == 200) {
        return ProcessoDetalhe.fromJson(response.data);
      } else if (response.statusCode == 400) {
        throw Exception('Código da imagem incorreto ou expirado.');
      } else {
        throw Exception('Falha ao buscar detalhes.');
      }
    });
