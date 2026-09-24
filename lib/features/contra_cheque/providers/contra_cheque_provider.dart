import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/api_client.dart';
import '../models/contra_cheque.dart';

class ContraChequeState {
  final bool isLoading;
  final List<Competencia> competencias;
  final Competencia? competenciaSelecionada;
  final ContraCheque? contrachequeAtual;
  final String? errorMessage;

  ContraChequeState({
    this.isLoading = false,
    this.competencias = const [],
    this.competenciaSelecionada,
    this.contrachequeAtual,
    this.errorMessage,
  });

  ContraChequeState copyWith({
    bool? isLoading,
    List<Competencia>? competencias,
    Competencia? competenciaSelecionada,
    ContraCheque? contrachequeAtual,
    String? errorMessage,
  }) {
    return ContraChequeState(
      isLoading: isLoading ?? this.isLoading,
      competencias: competencias ?? this.competencias,
      competenciaSelecionada:
          competenciaSelecionada ?? this.competenciaSelecionada,
      contrachequeAtual: contrachequeAtual ?? this.contrachequeAtual,
      errorMessage: errorMessage,
    );
  }
}

class ContraChequeNotifier extends Notifier<ContraChequeState> {
  @override
  ContraChequeState build() {
    _init();
    return ContraChequeState();
  }

  Future<void> _init() async {
    // Aguarda o build inicial terminar para poder usar o ref e os outros providers estarem prontos
    Future.microtask(() => carregarCompetencias());
  }

  Future<void> carregarCompetencias() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final dio = ref.read(dioProvider);
      final token = ref.read(authProvider).token ?? '';

      final response = await dio.get(
        '/contracheques/competencias',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final List<dynamic> data = response.data;
      final comps = data
          .map((e) => Competencia(mes: e['mes'] as int, ano: e['ano'] as int))
          .toList();

      // Ordenar decrescente
      comps.sort((a, b) {
        if (a.ano != b.ano) return b.ano.compareTo(a.ano);
        return b.mes.compareTo(a.mes);
      });

      state = state.copyWith(competencias: comps, isLoading: false);

      if (comps.isNotEmpty) {
        await buscarContracheque(comps.first);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Nenhum contracheque disponível.',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar competências: ${e.message}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
    }
  }

  Future<void> buscarContracheque(Competencia comp) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      competenciaSelecionada: comp,
    );
    try {
      final dio = ref.read(dioProvider);
      final token = ref.read(authProvider).token ?? '';

      final response = await dio.get(
        '/contracheques/${comp.mes}/${comp.ano}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;

      final String baseUrl = dio.options.baseUrl;
      final String pdfUrl =
          '$baseUrl/contracheques/${comp.mes}/${comp.ano}/pdf';

      final List<dynamic> lancs = data['lancamentos'] ?? [];
      final List<LancamentoContracheque> parsedLancamentos = lancs
          .map(
            (l) => LancamentoContracheque(
              codigo: l['codigo']?.toString() ?? '',
              descricao: l['descricao'] ?? '',
              valor: (l['valor'] as num?)?.toDouble() ?? 0.0,
              tipo: l['tipo'] ?? 'V',
            ),
          )
          .toList();

      final cheque = ContraCheque(
        id: '${comp.mes}_${comp.ano}',
        mes: comp.mes,
        ano: comp.ano,
        valorBruto: (data['totalVantagens'] as num?)?.toDouble() ?? 0.0,
        totalDescontos: (data['totalDescontos'] as num?)?.toDouble() ?? 0.0,
        valorLiquido: (data['salarioLiquido'] as num?)?.toDouble() ?? 0.0,
        lancamentos: parsedLancamentos,
        linkPdf: pdfUrl,
      );

      state = state.copyWith(contrachequeAtual: cheque, isLoading: false);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        state = state.copyWith(
          isLoading: false,
          contrachequeAtual: null,
          errorMessage: 'Nenhum contracheque encontrado para esta competência.',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Erro ao carregar contracheque: ${e.message}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro inesperado: $e',
      );
    }
  }

  void selecionarMesAnterior() {
    if (state.competenciaSelecionada == null || state.competencias.isEmpty) {
      return;
    }
    final currentIndex = state.competencias.indexOf(
      state.competenciaSelecionada!,
    );
    if (currentIndex < state.competencias.length - 1) {
      buscarContracheque(state.competencias[currentIndex + 1]);
    }
  }

  void selecionarProximoMes() {
    if (state.competenciaSelecionada == null || state.competencias.isEmpty) {
      return;
    }
    final currentIndex = state.competencias.indexOf(
      state.competenciaSelecionada!,
    );
    if (currentIndex > 0) {
      buscarContracheque(state.competencias[currentIndex - 1]);
    }
  }
}

final contraChequeProvider =
    NotifierProvider<ContraChequeNotifier, ContraChequeState>(() {
      return ContraChequeNotifier();
    });
