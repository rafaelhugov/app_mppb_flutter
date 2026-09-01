import 'dart:async';
import 'dart:convert';

import 'package:app_mppb_flutter/features/concessao_afastamento/models/operacao_solicitacao_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/repositories/concessao_afastamento_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dio dio;
  late _FakeAdapter adapter;
  late ConcessaoAfastamentoRepository repository;

  setUp(() {
    adapter = _FakeAdapter();
    dio = Dio(BaseOptions(baseUrl: 'http://mobile.local'));
    dio.httpClientAdapter = adapter;
    repository = ConcessaoAfastamentoRepository(dio);
  });

  test('consulta sugestoes ao selecionar data inicial', () async {
    adapter.enqueueJson([
      {
        'numeroDias': 10,
        'dataInicial': '10/01/2027',
        'dataFinal': '19/01/2027',
      },
      {
        'numeroDias': 15,
        'dataInicial': '10/01/2027',
        'dataFinal': '24/01/2027',
      },
    ]);

    final sugestoes = await repository.buscarSugestoesDatasFinais(
      token: 'token',
      concessaoId: 123,
      dataInicial: DateTime(2027, 1, 10),
    );

    expect(
      adapter.last.uri.path,
      '/api/recursos-humanos/concessoes/123/sugestoes-datas-finais',
    );
    expect(adapter.last.uri.queryParameters['dataInicial'], '10/01/2027');
    expect(sugestoes, hasLength(2));
    expect(sugestoes.first.dataInicialFormatada, '10/01/2027');
    expect(sugestoes.first.dataFinalFormatada, '19/01/2027');
    expect(sugestoes.first.numeroDias, 10);
  });

  test(
    'descarta sugestoes de uma dataInicial diferente da selecionada',
    () async {
      adapter.enqueueJson([
        {
          'numeroDias': 10,
          'dataInicial': '09/01/2027',
          'dataFinal': '18/01/2027',
        },
        {
          'numeroDias': 15,
          'dataInicial': '10/01/2027',
          'dataFinal': '24/01/2027',
        },
      ]);

      final sugestoes = await repository.buscarSugestoesDatasFinais(
        token: 'token',
        concessaoId: 123,
        dataInicial: DateTime(2027, 1, 10),
      );

      expect(sugestoes, hasLength(1));
      expect(sugestoes.single.numeroDias, 15);
      expect(sugestoes.single.dataInicialFormatada, '10/01/2027');
    },
  );

  test('sugestao sem numeroDias falha no contrato estrito', () async {
    adapter.enqueueJson([
      {'dataInicial': '10/01/2027', 'dataFinal': '19/01/2027'},
    ]);

    expect(
      () => repository.buscarSugestoesDatasFinais(
        token: 'token',
        concessaoId: 123,
        dataInicial: DateTime(2027, 1, 10),
      ),
      throwsFormatException,
    );
  });

  test('sugestao sem dataFinal falha no contrato estrito', () async {
    adapter.enqueueJson([
      {'numeroDias': 10, 'dataInicial': '10/01/2027'},
    ]);

    expect(
      () => repository.buscarSugestoesDatasFinais(
        token: 'token',
        concessaoId: 123,
        dataInicial: DateTime(2027, 1, 10),
      ),
      throwsFormatException,
    );
  });

  test('resposta string nao e sugestao valida', () async {
    adapter.enqueueJson('19/01/2027');

    expect(
      () => repository.buscarSugestoesDatasFinais(
        token: 'token',
        concessaoId: 123,
        dataInicial: DateTime(2027, 1, 10),
      ),
      throwsFormatException,
    );
  });

  test(
    'lista vazia de sugestoes retorna vazia e nao inventa periodo',
    () async {
      adapter.enqueueJson([]);

      final sugestoes = await repository.buscarSugestoesDatasFinais(
        token: 'token',
        concessaoId: 123,
        dataInicial: DateTime(2027, 1, 10),
      );

      expect(sugestoes, isEmpty);
    },
  );

  test(
    'post de marcacao usa id real da concessao e numeroDias selecionado',
    () async {
      adapter.enqueueJson({'ok': true});

      await repository.solicitarGozo(
        token: 'token',
        concessaoId: 987,
        dataInicial: DateTime(2027, 1, 10),
        numeroDias: 15,
      );

      expect(
        adapter.last.uri.path,
        '/api/recursos-humanos/concessoes/987/solicitacoes',
      );
      expect(adapter.last.method, 'POST');
      expect(adapter.last.body, {
        'dataInicial': '10/01/2027',
        'numeroDias': 15,
      });
      expect(adapter.last.responseType, ResponseType.plain);
    },
  );

  test('operacoes exibidas seguem retorno de operacoes', () async {
    adapter.enqueueJson({
      'operacoes': ['cancelamentos', 'adiamentos', 'suspensoes-parciais'],
    });

    final operacoes = await repository.buscarOperacoesSolicitacao(
      token: 'token',
      solicitacaoId: 506,
    );

    expect(
      adapter.last.uri.path,
      '/api/recursos-humanos/solicitacoes/506/operacoes',
    );
    expect(operacoes, [
      OperacaoSolicitacaoConcessao.cancelar,
      OperacaoSolicitacaoConcessao.adiar,
      OperacaoSolicitacaoConcessao.suspenderParcialmente,
    ]);
  });

  test('adiamento envia data no contrato da api', () async {
    adapter.enqueueJson({'ok': true});

    await repository.executarOperacaoSolicitacao(
      token: 'token',
      solicitacaoId: 506,
      operacao: OperacaoSolicitacaoConcessao.adiar,
      data: DateTime(2027, 8, 3),
    );

    expect(
      adapter.last.uri.path,
      '/api/recursos-humanos/solicitacoes/506/adiamentos',
    );
    expect(adapter.last.method, 'POST');
    expect(adapter.last.body, {'dataAdiamento': '03/08/2027'});
    expect(adapter.last.responseType, ResponseType.plain);
  });

  test('antecipacao envia data no contrato da api', () async {
    adapter.enqueueJson({'ok': true});

    await repository.executarOperacaoSolicitacao(
      token: 'token',
      solicitacaoId: 506,
      operacao: OperacaoSolicitacaoConcessao.antecipar,
      data: DateTime(2027, 8, 3),
    );

    expect(
      adapter.last.uri.path,
      '/api/recursos-humanos/solicitacoes/506/antecipacoes',
    );
    expect(adapter.last.method, 'POST');
    expect(adapter.last.body, {'dataAntecipacao': '03/08/2027'});
    expect(adapter.last.responseType, ResponseType.plain);
  });

  test('suspensao parcial envia intervalo no contrato da api', () async {
    adapter.enqueueJson({'ok': true});

    await repository.executarOperacaoSolicitacao(
      token: 'token',
      solicitacaoId: 506,
      operacao: OperacaoSolicitacaoConcessao.suspenderParcialmente,
      data: DateTime(2027, 8, 3),
      dataFim: DateTime(2027, 8, 4),
    );

    expect(
      adapter.last.uri.path,
      '/api/recursos-humanos/solicitacoes/506/suspensoes-parciais',
    );
    expect(adapter.last.body, {
      'datasSuspensoes': [
        {
          'dataSuspensaoInicial': '03/08/2027',
          'dataSuspensaoFinal': '04/08/2027',
        },
      ],
    });
  });
}

class _CapturedRequest {
  final Uri uri;
  final String method;
  final dynamic body;
  final ResponseType? responseType;

  const _CapturedRequest({
    required this.uri,
    required this.method,
    required this.body,
    required this.responseType,
  });
}

class _FakeAdapter implements HttpClientAdapter {
  final _responses = <dynamic>[];
  late _CapturedRequest last;

  void enqueueJson(dynamic json) {
    _responses.add(json);
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = _CapturedRequest(
      uri: options.uri,
      method: options.method,
      body: options.data,
      responseType: options.responseType,
    );
    final data = _responses.isEmpty ? null : _responses.removeAt(0);
    return ResponseBody.fromString(
      jsonEncode(data),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
