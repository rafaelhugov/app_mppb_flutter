import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/processo.dart';

class ConsultaProcessosState {
  final bool isLoading;
  final List<ProcessoResumo> resultados;
  final String? errorMessage;
  final bool searched;

  ConsultaProcessosState({
    this.isLoading = false,
    this.resultados = const [],
    this.errorMessage,
    this.searched = false,
  });

  ConsultaProcessosState copyWith({
    bool? isLoading,
    List<ProcessoResumo>? resultados,
    String? errorMessage,
    bool? searched,
  }) {
    return ConsultaProcessosState(
      isLoading: isLoading ?? this.isLoading,
      resultados: resultados ?? this.resultados,
      errorMessage: errorMessage,
      searched: searched ?? this.searched,
    );
  }
}

class ConsultaProcessosNotifier extends Notifier<ConsultaProcessosState> {
  @override
  ConsultaProcessosState build() {
    return ConsultaProcessosState();
  }

  Future<void> buscarProcessos(Map<String, dynamic> filtros) async {
    state = state.copyWith(isLoading: true, errorMessage: null, searched: true);

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/api/public/v1/processos/consulta',
        data: filtros,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        final list = data.map((item) => ProcessoResumo.fromJson(item)).toList();
        state = state.copyWith(isLoading: false, resultados: list);
      } else {
        throw Exception('Status: ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro na busca: $e');
    }
  }

  void limpar() {
    state = ConsultaProcessosState();
  }
}

final consultaProcessosProvider = NotifierProvider<ConsultaProcessosNotifier, ConsultaProcessosState>(() {
  return ConsultaProcessosNotifier();
});

// CAPTCHA Provider
final captchaProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
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
  int get hashCode => idProcesso.hashCode ^ captchaToken.hashCode ^ captchaValue.hashCode;
}

final processoDetalhesProvider = FutureProvider.autoDispose.family<ProcessoDetalhe, ProcessoDetalheParams>((ref, params) async {
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
