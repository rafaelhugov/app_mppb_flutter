import 'package:app_mppb_flutter/features/designacoes/models/designacao_ativa.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseia designacao ativa e formata periodo com data final', () {
    final response = DesignacoesAtivasResponse.fromJson({
      'tipoUsuario': 'MEMBRO',
      'designacoes': [
        {
          'id': 1002,
          'tipoCodigo': 'S',
          'tipoDescricao': 'Substituição Cumulativa',
          'titulo': '15º Procurador de Justiça',
          'dataInicial': '2026-06-16',
          'dataFinal': '2026-07-30',
        },
      ],
    });

    expect(response.tipoUsuario, 'MEMBRO');
    expect(response.designacoes, hasLength(1));
    expect(response.designacoes.first.tipoDescricao, 'Substituição Cumulativa');
    expect(response.designacoes.first.periodo, '16/06/2026 até 30/07/2026');
  });

  test('formata periodo sem data final como desde', () {
    final designacao = DesignacaoAtiva.fromJson({
      'id': 1001,
      'tipoCodigo': 'T',
      'tipoDescricao': 'Titularidade',
      'titulo': '16º Procurador de Justiça',
      'dataInicial': '2019-01-07',
      'dataFinal': null,
    });

    expect(designacao.periodo, 'Desde 07/01/2019');
  });

  test('omite ato tecnico iniciado por INI recebido da API', () {
    final designacao = DesignacaoAtiva.fromJson({
      'id': 2001,
      'tipoCodigo': 'F',
      'tipoDescricao': 'Função',
      'titulo': 'Exercer atribuições',
      'dataInicial': '2025-10-23',
      'ato': ' INI_EDUARDO_promMulher',
      'dataPublicacao': '2025-10-22',
    });

    expect(designacao.ato, isNull);
    expect(designacao.dataPublicacao, isNull);
    expect(designacao.periodo, 'Desde 23/10/2025');
  });
}
