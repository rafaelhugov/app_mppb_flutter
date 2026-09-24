import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import '../models/ausencia_calendario.dart';
import '../models/concessao_afastamento.dart';
import '../models/operacao_solicitacao_concessao.dart';
import '../models/solicitacao_concessao.dart';
import '../models/status_solicitacao_concessao.dart';
import '../models/tipo_solicitacao_concessao.dart';
import '../models/sugestao_data_final.dart';

class ConcessaoAfastamentoRepository {
  final Dio dio;

  const ConcessaoAfastamentoRepository(this.dio);

  Future<List<ConcessaoAfastamento>> buscarConcessoesVigentes({
    required String token,
  }) async {
    final response = await dio.get(
      '/api/recursos-humanos/minhas-concessoes-folga',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        extra: {'skipAuthLogout': true},
      ),
    );
    if (response.data is! List) {
      throw Exception('Formato inesperado (Concessoes): ${response.data}');
    }
    final data = response.data as List<dynamic>? ?? [];
    final concessoes = data
        .map(
          (json) => ConcessaoAfastamento.fromJson(json as Map<String, dynamic>),
        )
        .toList();
    final totalSolicitacoes = concessoes.fold<int>(
      0,
      (total, concessao) => total + concessao.solicitacoes.length,
    );
    debugPrint(
      '[ConcessaoAfastamento] Concessoes carregadas: '
      '${concessoes.length} concessao(oes), '
      '$totalSolicitacoes solicitacao(oes) vinculada(s)',
    );
    return concessoes;
  }

  Future<List<AusenciaCalendario>> buscarAusenciasCalendario({
    required String token,
    int? mes,
    int? ano,
  }) async {
    final query = <String, dynamic>{};
    if (mes != null) query['mes'] = mes;
    if (ano != null) query['ano'] = ano;

    final response = await dio.get(
      '/api/recursos-humanos/minhas-ausencias',
      queryParameters: query,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
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

  Future<SolicitacaoConcessao?> solicitarGozo({
    required String token,
    required int concessaoId,
    required DateTime dataInicial,
    required int numeroDias,
  }) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final body = {
      'dataInicial': dateFormat.format(dataInicial),
      'numeroDias': numeroDias,
    };

    debugPrint(
      '[ConcessaoAfastamento] Solicitando gozo: '
      'concessao=$concessaoId body=$body',
    );

    try {
      final response = await dio.post(
        '/api/recursos-humanos/concessoes/$concessaoId/solicitacoes',
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          extra: {'skipAuthLogout': true},
          responseType: ResponseType.plain,
        ),
      );

      debugPrint(
        '[ConcessaoAfastamento] Gozo solicitado: '
        'concessao=$concessaoId status=${response.statusCode} '
        'response=${response.data}',
      );
      return _parseSolicitacaoCriada(
        response.data,
        dataInicial: dataInicial,
        numeroDias: numeroDias,
      );
    } on DioException catch (e) {
      debugPrint(
        '[ConcessaoAfastamento] Solicitacao de gozo falhou: '
        'concessao=$concessaoId status=${e.response?.statusCode} '
        'response=${e.response?.data}',
      );
      rethrow;
    }
  }

  SolicitacaoConcessao? _parseSolicitacaoCriada(
    dynamic data, {
    required DateTime dataInicial,
    required int numeroDias,
  }) {
    final json = _decodeMap(data);
    if (json == null) return null;

    final id = _intValue(json['id']);
    final inicio = _dateValue(json['dataInicio']) ?? dataInicial;
    final fim =
        _dateValue(json['dataFim']) ??
        inicio.add(Duration(days: numeroDias - 1));
    if (id == null) return null;

    return SolicitacaoConcessao(
      id: id,
      tipo: TipoSolicitacaoConcessao.gozo,
      tipoOriginal: 'Gozo',
      inicio: inicio,
      fim: fim,
      status: StatusSolicitacaoConcessao.fromJson(json['status']?.toString()),
      statusOriginal: json['status']?.toString(),
      diasInformados: _intValue(json['numeroDias']) ?? numeroDias,
    );
  }

  Map<String, dynamic>? _decodeMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is! String) return null;

    final text = data.trim();
    if (text.isEmpty || !text.startsWith('{')) return null;
    final decoded = jsonDecode(text);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return null;
  }

  int? _intValue(dynamic value) {
    if (value is num) return value.toInt();
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  DateTime? _dateValue(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    final parsedIso = DateTime.tryParse(text);
    if (parsedIso != null) return parsedIso;
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(text);
    } on FormatException {
      return null;
    }
  }

  Future<List<SugestaoDataFinal>> buscarSugestoesDatasFinais({
    required String token,
    required int concessaoId,
    required DateTime dataInicial,
  }) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final response = await dio.get(
      '/api/recursos-humanos/concessoes/$concessaoId/sugestoes-datas-finais',
      queryParameters: {'dataInicial': dateFormat.format(dataInicial)},
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
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
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
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

    debugPrint(
      '[ConcessaoAfastamento] Executando operacao: '
      'solicitacao=$solicitacaoId operacao=${operacao.name} body=$body',
    );

    try {
      final response = await dio.post(
        '/api/recursos-humanos/solicitacoes/$solicitacaoId/$endpoint',
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          extra: {'skipAuthLogout': true},
          responseType: ResponseType.plain,
        ),
      );

      debugPrint(
        '[ConcessaoAfastamento] Operacao concluida: '
        'solicitacao=$solicitacaoId operacao=${operacao.name} '
        'status=${response.statusCode} response=${response.data}',
      );
    } on DioException catch (e) {
      debugPrint(
        '[ConcessaoAfastamento] Operacao falhou: '
        'solicitacao=$solicitacaoId operacao=${operacao.name} '
        'status=${e.response?.statusCode} response=${e.response?.data}',
      );
      rethrow;
    }
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

final concessaoAfastamentoRepositoryProvider =
    Provider<ConcessaoAfastamentoRepository>((ref) {
      return ConcessaoAfastamentoRepository(ref.read(dioProvider));
    });
