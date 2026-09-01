import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import '../models/ausencia_calendario.dart';
import '../models/concessao_folga.dart';
import '../models/operacao_solicitacao_concessao.dart';
import '../models/sugestao_data_final.dart';

class ConcessaoFolgaRepository {
  final Dio dio;

  const ConcessaoFolgaRepository(this.dio);

  Future<List<ConcessaoFolga>> buscarConcessoesVigentes({
    required String token,
  }) async {
    final response = await dio.get(
      '/api/recursos-humanos/minhas-concessoes-folga',
      queryParameters: {'token': token},
      options: Options(
        headers: {'Authorization': 'Token $token'},
        extra: {'skipAuthLogout': true},
      ),
    );
    if (response.data is! List) {
      throw Exception('Formato inesperado (Concessoes): ${response.data}');
    }
    final data = response.data as List<dynamic>? ?? [];
    return data
        .map((json) => ConcessaoFolga.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<AusenciaCalendario>> buscarAusenciasCalendario({
    required String token,
    int? mes,
    int? ano,
  }) async {
    final query = <String, dynamic>{'token': token};
    if (mes != null) query['mes'] = mes;
    if (ano != null) query['ano'] = ano;

    final response = await dio.get(
      '/api/recursos-humanos/minhas-ausencias',
      queryParameters: query,
      options: Options(
        headers: {'Authorization': 'Token $token'},
        extra: {'skipAuthLogout': true},
      ),
    );
    if (response.data is! List) {
      throw Exception('Formato inesperado (Ausencias): ${response.data}');
    }
    final data = response.data as List<dynamic>? ?? [];
    return data
        .map(
          (json) => AusenciaCalendario.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> solicitarGozo({
    required String token,
    required int concessaoId,
    required DateTime dataInicial,
    required int numeroDias,
  }) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    await dio.post(
      '/api/recursos-humanos/concessoes/$concessaoId/solicitacoes',
      queryParameters: {'token': token},
      data: {
        'dataInicial': dateFormat.format(dataInicial),
        'numeroDias': numeroDias,
      },
      options: Options(
        headers: {'Authorization': 'Token $token'},
        extra: {'skipAuthLogout': true},
      ),
    );
  }

  Future<List<SugestaoDataFinal>> buscarSugestoesDatasFinais({
    required String token,
    required int concessaoId,
    required DateTime dataInicial,
  }) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final response = await dio.get(
      '/api/recursos-humanos/concessoes/$concessaoId/sugestoes-datas-finais',
      queryParameters: {
        'token': token,
        'dataInicial': dateFormat.format(dataInicial),
      },
      options: Options(
        headers: {'Authorization': 'Token $token'},
        extra: {'skipAuthLogout': true},
      ),
    );
    return _parseSugestoes(response.data, dataInicial: dataInicial);
  }

  List<SugestaoDataFinal> _parseSugestoes(
    dynamic data, {
    required DateTime dataInicial,
  }) {
    if (data == null) return const [];
    if (data is List) {
      return data
          .map(
            (item) => SugestaoDataFinal.fromJson(item as Map<String, dynamic>),
          )
          .where((sugestao) => sugestao.pertenceADataInicial(dataInicial))
          .toList();
    }
    throw const FormatException(
      'Formato inesperado para sugestões de datas finais.',
    );
  }

  Future<List<OperacaoSolicitacaoConcessao>> buscarOperacoesSolicitacao({
    required String token,
    required int solicitacaoId,
  }) async {
    final response = await dio.get(
      '/api/recursos-humanos/solicitacoes/$solicitacaoId/operacoes',
      queryParameters: {'token': token},
      options: Options(
        headers: {'Authorization': 'Token $token'},
        extra: {'skipAuthLogout': true},
      ),
    );

    final operacoes = _extractOperacoes(response.data)
        .map(operacaoSolicitacaoFromJson)
        .whereType<OperacaoSolicitacaoConcessao>()
        .toSet()
        .toList();
    operacoes.sort((a, b) => a.index.compareTo(b.index));
    return operacoes;
  }

  Future<void> executarOperacaoSolicitacao({
    required String token,
    required int solicitacaoId,
    required OperacaoSolicitacaoConcessao operacao,
    DateTime? data,
    DateTime? dataFim,
  }) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dataFormatada = data == null ? null : dateFormat.format(data);
    final dataFinalFormatada = dataFim == null
        ? null
        : dateFormat.format(dataFim);
    final endpoint = switch (operacao) {
      OperacaoSolicitacaoConcessao.cancelar => 'cancelamentos',
      OperacaoSolicitacaoConcessao.adiar => 'adiamentos',
      OperacaoSolicitacaoConcessao.antecipar => 'antecipacoes',
      OperacaoSolicitacaoConcessao.interromper => 'interrupcoes',
      OperacaoSolicitacaoConcessao.suspenderParcialmente =>
        'suspensoes-parciais',
      OperacaoSolicitacaoConcessao.suspenderIntegralmente =>
        'suspensoes-integrais',
    };
    final body = switch (operacao) {
      OperacaoSolicitacaoConcessao.cancelar ||
      OperacaoSolicitacaoConcessao.suspenderIntegralmente => null,
      OperacaoSolicitacaoConcessao.adiar => {'dataAdiamento': dataFormatada},
      OperacaoSolicitacaoConcessao.antecipar => {
        'dataAntecipacao': dataFormatada,
      },
      OperacaoSolicitacaoConcessao.interromper => {
        'dataInterrupcao': dataFormatada,
      },
      OperacaoSolicitacaoConcessao.suspenderParcialmente => {
        'datasSuspensoes': [
          {
            'dataSuspensaoInicial': dataFormatada,
            'dataSuspensaoFinal': dataFinalFormatada ?? dataFormatada,
          },
        ],
      },
    };

    await dio.post(
      '/api/recursos-humanos/solicitacoes/$solicitacaoId/$endpoint',
      queryParameters: {'token': token},
      data: body,
      options: Options(
        headers: {'Authorization': 'Token $token'},
        extra: {'skipAuthLogout': true},
      ),
    );
  }

  List<dynamic> _extractOperacoes(dynamic data) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final operacoes = data['operacoes'];
      if (operacoes is List) return operacoes;
    }
    return const [];
  }
}

final concessaoFolgaRepositoryProvider = Provider<ConcessaoFolgaRepository>((
  ref,
) {
  return ConcessaoFolgaRepository(ref.read(dioProvider));
});
