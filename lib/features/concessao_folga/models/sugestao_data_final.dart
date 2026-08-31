import 'package:intl/intl.dart';

import 'solicitacao_concessao.dart';

class SugestaoDataFinal {
  static final _brDateFormat = DateFormat('dd/MM/yyyy');

  final DateTime dataFinal;
  final int numeroDias;
  final String? descricao;

  const SugestaoDataFinal({
    required this.dataFinal,
    required this.numeroDias,
    this.descricao,
  });

  factory SugestaoDataFinal.fromJson(
    dynamic json, {
    required DateTime dataInicial,
  }) {
    if (json is String || json is num || json is bool) {
      final dataFinal = _parseDate(json.toString());
      return SugestaoDataFinal(
        dataFinal: dataFinal,
        numeroDias: calcularQuantidadeDias(dataInicial, dataFinal),
      );
    }

    if (json is Map<String, dynamic>) {
      final rawDataFinal =
          json['dataFinal'] ??
          json['dataFim'] ??
          json['fim'] ??
          json['data'] ??
          json['dtFinal'] ??
          json['dataFinalFormatada'];
      final dataFinal = _parseDate(rawDataFinal?.toString());
      final rawNumeroDias =
          json['numeroDias'] ??
          json['quantidadeDias'] ??
          json['qtdDias'] ??
          json['dias'];
      return SugestaoDataFinal(
        dataFinal: dataFinal,
        numeroDias:
            (rawNumeroDias as num?)?.toInt() ??
            calcularQuantidadeDias(dataInicial, dataFinal),
        descricao:
            json['descricao']?.toString() ??
            json['label']?.toString() ??
            json['nome']?.toString(),
      );
    }

    final dataFinal = _parseDate(json?.toString());
    return SugestaoDataFinal(
      dataFinal: dataFinal,
      numeroDias: calcularQuantidadeDias(dataInicial, dataFinal),
    );
  }

  String get dataFinalFormatada => _brDateFormat.format(dataFinal);

  String get resumo => descricao == null || descricao!.trim().isEmpty
      ? '$dataFinalFormatada - $numeroDias dia(s)'
      : '${descricao!.trim()} - $dataFinalFormatada - $numeroDias dia(s)';

  static DateTime _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      throw const FormatException('Sugestão sem data final.');
    }
    final text = value.trim();
    final iso = DateTime.tryParse(text);
    if (iso != null) return iso;
    return _brDateFormat.parseStrict(text);
  }
}
