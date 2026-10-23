import 'package:flutter_test/flutter_test.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/ausencia_calendario.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/concessao_afastamento.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/solicitacao_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/status_solicitacao_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/sugestao_data_final.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/tipo_ausencia.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/tipo_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/tipo_solicitacao_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/services/concessao_afastamento_service.dart';

void main() {
  group('parsing', () {
    test('normaliza tipos de concessao conhecidos e desconhecidos', () {
      expect(TipoConcessao.fromJson('FÉRIAS'), TipoConcessao.ferias);
      expect(TipoConcessao.fromJson('ferias'), TipoConcessao.ferias);
      expect(TipoConcessao.fromJson('L'), TipoConcessao.licencaPremio);
      expect(TipoConcessao.fromJson('LICENÇA'), TipoConcessao.licencaPremio);
      expect(TipoConcessao.fromJson('E'), TipoConcessao.licencaEleitoral);
      expect(TipoConcessao.fromJson('P'), TipoConcessao.plantao);
      expect(TipoConcessao.fromJson(null), TipoConcessao.desconhecido);
    });

    test('normaliza tipos de ausencia com acentos e caixa', () {
      expect(TipoAusencia.fromJson('Férias'), TipoAusencia.ferias);
      expect(
        TipoAusencia.fromJson('licença eleitoral'),
        TipoAusencia.licencaEleitoral,
      );
      expect(
        TipoAusencia.fromJson('AFASTAMENTO POR DIÁRIAS'),
        TipoAusencia.diarias,
      );
      expect(TipoAusencia.fromJson('valor novo'), TipoAusencia.outros);
    });

    test('normaliza status e tipo de solicitacao desconhecidos', () {
      expect(
        StatusSolicitacaoConcessao.fromJson('DEFERIDO'),
        StatusSolicitacaoConcessao.deferido,
      );
      expect(
        StatusSolicitacaoConcessao.fromJson('MIGRADO'),
        StatusSolicitacaoConcessao.migrado,
      );
      expect(
        StatusSolicitacaoConcessao.fromJson('X'),
        StatusSolicitacaoConcessao.desconhecido,
      );
      expect(
        TipoSolicitacaoConcessao.fromJson('Gozo coletivo'),
        TipoSolicitacaoConcessao.gozoColetivo,
      );
      expect(
        TipoSolicitacaoConcessao.fromJson('Conversão de férias'),
        TipoSolicitacaoConcessao.conversao,
      );
      expect(
        TipoSolicitacaoConcessao.fromJson(null),
        TipoSolicitacaoConcessao.desconhecido,
      );
    });
  });

  group('datas', () {
    test('calcula dias de forma inclusiva', () {
      expect(
        calcularQuantidadeDias(DateTime(2026, 7, 1), DateTime(2026, 7, 1)),
        1,
      );
      expect(
        calcularQuantidadeDias(DateTime(2026, 7, 1), DateTime(2026, 7, 2)),
        2,
      );
    });

    test('rejeita data final anterior a inicial', () {
      expect(
        () =>
            calcularQuantidadeDias(DateTime(2026, 7, 2), DateTime(2026, 7, 1)),
        throwsFormatException,
      );
    });

    test('identifica divergencia entre dias informados e calculados', () {
      final solicitacao = SolicitacaoConcessao(
        id: 1,
        tipo: TipoSolicitacaoConcessao.gozo,
        inicio: DateTime(2026, 7, 1),
        fim: DateTime(2026, 7, 2),
        status: StatusSolicitacaoConcessao.deferido,
        diasInformados: 3,
      );
      expect(solicitacao.diasCalculados, 2);
      expect(solicitacao.possuiDivergenciaDias, isTrue);
    });

    test('aceita movimentacao sem periodo completo vinda da view', () {
      final solicitacao = SolicitacaoConcessao.fromJson({
        'id': 506839,
        'tipo': 'Interrupção',
        'inicio': null,
        'fim': '2026-09-16',
        'status': 'P',
        'diasInformados': 12,
      });

      expect(solicitacao.tipo, TipoSolicitacaoConcessao.interrupcao);
      expect(solicitacao.inicio, isNull);
      expect(solicitacao.fim, DateTime(2026, 9, 16));
      expect(solicitacao.isMovimentacao, isTrue);
      expect(solicitacao.isGozo, isFalse);
      expect(solicitacao.diasCalculados, isNull);
      expect(solicitacao.possuiDiasParaRetorno, isTrue);
      expect(solicitacao.possuiDivergenciaDias, isFalse);
    });

    test('parseia sugestao no contrato real da API RH', () {
      final sugestao = SugestaoDataFinal.fromJson({
        'numeroDias': 10,
        'dataInicial': '08/09/2026',
        'dataFinal': '17/09/2026',
      });

      expect(sugestao.numeroDias, 10);
      expect(sugestao.dataInicial, DateTime(2026, 9, 8));
      expect(sugestao.dataFinal, DateTime(2026, 9, 17));
      expect(sugestao.dataInicialFormatada, '08/09/2026');
      expect(sugestao.dataFinalFormatada, '17/09/2026');
    });

    test('numeroDias e dataFinal sao obtidos diretamente da resposta', () {
      final sugestao = SugestaoDataFinal.fromJson({
        'numeroDias': 15,
        'dataInicial': '08/09/2026',
        'dataFinal': '22/09/2026',
      });

      expect(sugestao.numeroDias, 15);
      expect(sugestao.dataFinal, DateTime(2026, 9, 22));
      expect(sugestao.resumo, '22/09/2026 - 15 dia(s)');
    });

    test('sugestao sem numeroDias e invalida', () {
      expect(
        () => SugestaoDataFinal.fromJson({
          'dataInicial': '08/09/2026',
          'dataFinal': '17/09/2026',
        }),
        throwsFormatException,
      );
    });

    test('sugestao sem dataFinal e invalida', () {
      expect(
        () => SugestaoDataFinal.fromJson({
          'numeroDias': 10,
          'dataInicial': '08/09/2026',
        }),
        throwsFormatException,
      );
    });

    test('aliases antigos nao sao aceitos como contrato valido', () {
      expect(
        () => SugestaoDataFinal.fromJson({
          'dias': 10,
          'data': '17/09/2026',
          'dataFim': '17/09/2026',
        }),
        throwsFormatException,
      );
    });

    test('string simples nao e sugestao valida', () {
      expect(
        () => SugestaoDataFinal.fromJson('17/09/2026' as dynamic),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('calendario', () {
    test(
      'agrupa intervalo atravessando mes e preserva duas ausencias no mesmo dia',
      () {
        final mes = DateTime(2019, 1);
        final ausencias = [
          AusenciaCalendario(
            id: '1',
            tipo: TipoAusencia.ferias,
            descricao: 'Férias',
            dataInicio: DateTime(2018, 12, 20),
            dataFim: DateTime(2019, 2, 10),
          ),
          AusenciaCalendario(
            id: '2',
            tipo: TipoAusencia.plantao,
            descricao: 'Plantão',
            dataInicio: DateTime(2019, 1, 1),
            dataFim: DateTime(2019, 1, 1),
          ),
        ];

        final porDia = ConcessaoAfastamentoService.agruparAusenciasPorDia(
          ausencias,
          mes,
        );
        expect(porDia[DateTime(2019, 1, 1)], hasLength(2));
        expect(porDia[DateTime(2019, 1, 31)], hasLength(1));
        expect(porDia[DateTime(2018, 12, 31)], isNull);
      },
    );
  });

  group('concessoes', () {
    test('parseia concessao sem solicitacao e periodo aquisitivo separado', () {
      final concessao = ConcessaoAfastamento.fromJson({
        'id': 10,
        'tipo': 'F',
        'diasConcedidos': 30,
        'saldoRestante': 30,
        'periodo': 1,
        'anoReferencia': 2026,
        'inicioPeriodoAquisitivo': '2025-01-01',
        'finalPeriodoAquisitivo': '2025-12-31',
        'solicitacoes': [],
      });

      expect(concessao.titulo, 'Férias - 1º período/2026');
      expect(concessao.solicitacoes, isEmpty);
      expect(concessao.inicioPeriodoAquisitivo, DateTime(2025, 1, 1));
    });

    test('parseia concessao com varias solicitacoes', () {
      final concessao = ConcessaoAfastamento.fromJson({
        'id': 11,
        'tipo': 'L',
        'diasConcedidos': 30,
        'saldoRestante': 0,
        'solicitacoes': [
          {
            'id': 1,
            'tipo': 'Gozo',
            'inicio': '2026-07-01',
            'fim': '2026-07-10',
            'status': 'DEFERIDO',
          },
          {
            'id': 2,
            'tipo': 'Adiamento',
            'inicio': '2026-08-01',
            'fim': '2026-08-05',
            'status': 'PENDENTE',
          },
        ],
      });

      expect(concessao.tipo, TipoConcessao.licencaPremio);
      expect(concessao.solicitacoes, hasLength(2));
    });

    test('formata titulo de Licença Especial com periodo aquisitivo', () {
      final concessao = ConcessaoAfastamento.fromJson({
        'id': 12,
        'tipo': 'L',
        'diasConcedidos': 90,
        'saldoRestante': 90,
        'inicioPeriodoAquisitivo': '2001-11-12',
        'finalPeriodoAquisitivo': '2006-11-12',
        'solicitacoes': [],
      });

      expect(
        concessao.titulo,
        'Licença Especial - 12/11/2001 a 12/11/2006',
      );
    });

    test(
      'formata titulo de Licença Especial a partir de descricaoOriginal quando datas forem nulas',
      () {
        final concessao = ConcessaoAfastamento.fromJson({
          'id': 13,
          'tipo': 'L',
          'diasConcedidos': 90,
          'saldoRestante': 90,
          'descricao': 'LICENÇA 12/11/2001 - 12/11/2006',
          'solicitacoes': [],
        });

        expect(
          concessao.titulo,
          'Licença Especial - 12/11/2001 a 12/11/2006',
        );
      },
    );
  });
}
