import 'package:app_mppb_flutter/features/contra_cheque/models/contra_cheque.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContraCheque model', () {
    test('parseia competencia por igualdade de mes e ano', () {
      expect(Competencia(mes: 9, ano: 2026), Competencia(mes: 9, ano: 2026));
      expect(
        Competencia(mes: 8, ano: 2026),
        isNot(Competencia(mes: 9, ano: 2026)),
      );
    });

    test('parseia lancamentos convertendo codigo e valor', () {
      final lancamento = LancamentoContracheque.fromJson({
        'codigo': 123,
        'descricao': 'Subsidio',
        'valor': 100.5,
        'tipo': 'V',
      });

      expect(lancamento.codigo, '123');
      expect(lancamento.valor, 100.5);
      expect(lancamento.toJson()['codigo'], '123');
    });

    test('parseia contracheque sem data, PDF ou lancamentos', () {
      final contracheque = ContraCheque.fromJson({
        'id': 77,
        'mes': 9,
        'ano': 2026,
        'valorBruto': 1000,
        'totalDescontos': 100,
        'valorLiquido': 900,
      });

      expect(contracheque.id, '77');
      expect(contracheque.dataPagamento, isNull);
      expect(contracheque.linkPdf, isNull);
      expect(contracheque.lancamentos, isEmpty);
      expect(contracheque.toJson()['valorLiquido'], 900.0);
    });
  });
}
