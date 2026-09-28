import 'package:app_mppb_flutter/features/ouvidoria/utils/input_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ouvidoria formatters', () {
    test('formata CPF removendo caracteres nao numericos', () {
      final formatter = CpfCnpjInputFormatter();

      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '123abc45678900'),
      );

      expect(result.text, '123.456.789-00');
      expect(result.selection.baseOffset, result.text.length);
    });

    test('limita e formata CNPJ', () {
      final formatter = CpfCnpjInputFormatter();

      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '11222333000199888'),
      );

      expect(result.text, '11.222.333/0001-99');
    });

    test('formata telefone celular e remove excesso', () {
      final formatter = TelefoneInputFormatter();

      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(text: '83999998888777'),
      );

      expect(result.text, '(83) 99999-8888');
      expect(result.selection.baseOffset, result.text.length);
    });
  });
}
