import 'status_solicitacao_concessao.dart';
import 'tipo_solicitacao_concessao.dart';

class SolicitacaoConcessao {
  final int id;
  final TipoSolicitacaoConcessao tipo;
  final String? tipoOriginal;
  final DateTime? inicio;
  final DateTime? fim;
  final StatusSolicitacaoConcessao status;
  final String? statusOriginal;
  final int? diasInformados;

  const SolicitacaoConcessao({
    required this.id,
    required this.tipo,
    this.tipoOriginal,
    this.inicio,
    this.fim,
    required this.status,
    this.statusOriginal,
    this.diasInformados,
  });

  factory SolicitacaoConcessao.fromJson(Map<String, dynamic> json) {
    return SolicitacaoConcessao(
      id: (json['id'] as num).toInt(),
      tipo: TipoSolicitacaoConcessao.fromJson(json['tipo'] as String?),
      tipoOriginal: json['tipoOriginal'] as String?,
      inicio: _date(json['inicio']),
      fim: _date(json['fim']),
      status: StatusSolicitacaoConcessao.fromJson(json['status'] as String?),
      statusOriginal: json['statusOriginal'] as String?,
      diasInformados: (json['diasInformados'] as num?)?.toInt(),
    );
  }

  bool get possuiPeriodoCompleto => inicio != null && fim != null;

  bool get isGozo {
    switch (tipo) {
      case TipoSolicitacaoConcessao.gozo:
      case TipoSolicitacaoConcessao.gozoColetivo:
      case TipoSolicitacaoConcessao.antecipacao:
      case TipoSolicitacaoConcessao.adiamento:
        return true;
      case TipoSolicitacaoConcessao.interrupcao:
      case TipoSolicitacaoConcessao.suspensaoParcial:
      case TipoSolicitacaoConcessao.suspensaoTotal:
      case TipoSolicitacaoConcessao.adiamentoSineDie:
      case TipoSolicitacaoConcessao.indenizacao:
      case TipoSolicitacaoConcessao.conversao:
      case TipoSolicitacaoConcessao.desconhecido:
        return false;
    }
  }

  bool get isMovimentacao => !isGozo;

  bool get possuiDiasParaRetorno =>
      isMovimentacao && diasInformados != null && diasInformados! > 0;

  int? get diasCalculados =>
      possuiPeriodoCompleto ? calcularQuantidadeDias(inicio!, fim!) : null;

  bool get possuiDivergenciaDias =>
      diasInformados != null &&
      diasCalculados != null &&
      diasInformados != diasCalculados;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
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
