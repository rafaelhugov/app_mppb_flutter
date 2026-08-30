import 'package:flutter/services.dart';

class CpfCnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.length <= 11) {
      // CPF: 000.000.000-00
      if (text.length > 9) {
        text = '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6, 9)}-${text.substring(9)}';
      } else if (text.length > 6) {
        text = '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6)}';
      } else if (text.length > 3) {
        text = '${text.substring(0, 3)}.${text.substring(3)}';
      }
    } else {
      // CNPJ: 00.000.000/0000-00
      if (text.length > 14) text = text.substring(0, 14);
      if (text.length > 12) {
        text = '${text.substring(0, 2)}.${text.substring(2, 5)}.${text.substring(5, 8)}/${text.substring(8, 12)}-${text.substring(12)}';
      } else if (text.length > 8) {
        text = '${text.substring(0, 2)}.${text.substring(2, 5)}.${text.substring(5, 8)}/${text.substring(8)}';
      } else if (text.length > 5) {
        text = '${text.substring(0, 2)}.${text.substring(2, 5)}.${text.substring(5)}';
      } else if (text.length > 2) {
        text = '${text.substring(0, 2)}.${text.substring(2)}';
      }
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 11) text = text.substring(0, 11);

    if (text.length > 10) {
      // (11) 90000-0000
      text = '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7)}';
    } else if (text.length > 6) {
      // (11) 0000-0000
      text = '(${text.substring(0, 2)}) ${text.substring(2, 6)}-${text.substring(6)}';
    } else if (text.length > 2) {
      text = '(${text.substring(0, 2)}) ${text.substring(2)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
