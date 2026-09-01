import 'package:intl/intl.dart';

class SugestaoDataFinal {
  static final _brDateFormat = DateFormat('dd/MM/yyyy');

  final int numeroDias;
  final DateTime dataInicial;
  final DateTime dataFinal;

  const SugestaoDataFinal({
    required this.numeroDias,
    required this.dataInicial,
    required this.dataFinal,
  });

  factory SugestaoDataFinal.fromJson(Map<String, dynamic> json) {
    final rawNumeroDias = json['numeroDias'];
    if (rawNumeroDias is! num) {
      throw const FormatException('Sugestão sem numeroDias.');
    }

    return SugestaoDataFinal(
      numeroDias: rawNumeroDias.toInt(),
      dataInicial: _parseDate(json['dataInicial']?.toString(), 'dataInicial'),
      dataFinal: _parseDate(json['dataFinal']?.toString(), 'dataFinal'),
    );
  }

  bool pertenceADataInicial(DateTime data) =>
      dataInicial.year == data.year &&
      dataInicial.month == data.month &&
      dataInicial.day == data.day;

  String get dataInicialFormatada => _brDateFormat.format(dataInicial);
  String get dataFinalFormatada => _brDateFormat.format(dataFinal);

  String get resumo => '$dataFinalFormatada - $numeroDias dia(s)';

  static DateTime _parseDate(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      throw FormatException('Sugestão sem $fieldName.');
    }
    return _brDateFormat.parseStrict(value.trim());
  }
}
