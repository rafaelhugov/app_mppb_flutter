import 'package:flutter_test/flutter_test.dart';
import 'package:app_mppb_flutter/features/processos/utils/processo_date_formatter.dart';

void main() {
  group('ProcessoDateFormatter', () {
    test('formata data e hora com separador espaco', () {
      expect(
        ProcessoDateFormatter.dateTime('2026-08-28 18:58:25.0'),
        '28/08/2026 18:58',
      );
    });

    test('formata data e hora com separador ISO', () {
      expect(
        ProcessoDateFormatter.dateTime('2026-08-28T18:58:25'),
        '28/08/2026 18:58',
      );
    });

    test('formata apenas a data', () {
      expect(ProcessoDateFormatter.date('2026-08-28'), '28/08/2026');
    });

    test('usa fallback para valor invalido', () {
      expect(ProcessoDateFormatter.dateTime('sem-data'), 'N/D');
    });
  });
}
