import 'status_solicitacao_concessao.dart';
import 'tipo_solicitacao_concessao.dart';

class SolicitacaoConcessao {
  final int id;
  final TipoSolicitacaoConcessao tipo;
  final String? tipoOriginal;
  final DateTime inicio;
  final DateTime fim;
  final StatusSolicitacaoConcessao status;
  final String? statusOriginal;
  final int? diasInformados;

  const SolicitacaoConcessao({
    required this.id,
    required this.tipo,
    this.tipoOriginal,
    required this.inicio,
    required this.fim,
    required this.status,
    this.statusOriginal,
    this.diasInformados,
  });

  factory SolicitacaoConcessao.fromJson(Map<String, dynamic> json) {
    return SolicitacaoConcessao(
      id: (json['id'] as num).toInt(),
      tipo: TipoSolicitacaoConcessao.fromJson(json['tipo'] as String?),
      tipoOriginal: json['tipoOriginal'] as String?,
      inicio: DateTime.parse(json['inicio'] as String),
      fim: DateTime.parse(json['fim'] as String),
      status: StatusSolicitacaoConcessao.fromJson(json['status'] as String?),
      statusOriginal: json['statusOriginal'] as String?,
      diasInformados: (json['diasInformados'] as num?)?.toInt(),
    );
  }

  int get diasCalculados => calcularQuantidadeDias(inicio, fim);

  bool get possuiDivergenciaDias =>
      diasInformados != null && diasInformados != diasCalculados;
}

DateTime normalizarData(DateTime date) =>
    DateTime(date.year, date.month, date.day);

int calcularQuantidadeDias(DateTime inicio, DateTime fim) {
  final dataInicio = normalizarData(inicio);
  final dataFim = normalizarData(fim);
  if (dataFim.isBefore(dataInicio)) {
    throw const FormatException('Período inválido');
  }
  return dataFim.difference(dataInicio).inDays + 1;
}
