import 'solicitacao_concessao.dart';
import 'tipo_concessao.dart';
import 'turno_eleitoral.dart';

class ConcessaoAfastamento {
  final int id;
  final TipoConcessao tipo;
  final String? descricaoOriginal;
  final int diasConcedidos;
  final int saldoRestante;
  final int? periodo;
  final int? anoReferencia;
  final DateTime? inicioPeriodoAquisitivo;
  final DateTime? finalPeriodoAquisitivo;
  final List<SolicitacaoConcessao> solicitacoes;

  const ConcessaoAfastamento({
    required this.id,
    required this.tipo,
    this.descricaoOriginal,
    required this.diasConcedidos,
    required this.saldoRestante,
    this.periodo,
    this.anoReferencia,
    this.inicioPeriodoAquisitivo,
    this.finalPeriodoAquisitivo,
    this.solicitacoes = const [],
  });

  factory ConcessaoAfastamento.fromJson(Map<String, dynamic> json) {
    final solicitacoesJson = json['solicitacoes'] as List<dynamic>? ?? [];
    return ConcessaoAfastamento(
      id: (json['id'] as num).toInt(),
      tipo: TipoConcessao.fromJson(json['tipo'] as String?),
      descricaoOriginal: json['descricaoOriginal'] as String?,
      diasConcedidos: (json['diasConcedidos'] as num?)?.toInt() ?? 0,
      saldoRestante: (json['saldoRestante'] as num?)?.toInt() ?? 0,
      periodo: (json['periodo'] as num?)?.toInt(),
      anoReferencia: (json['anoReferencia'] as num?)?.toInt(),
      inicioPeriodoAquisitivo: _date(json['inicioPeriodoAquisitivo']),
      finalPeriodoAquisitivo: _date(json['finalPeriodoAquisitivo']),
      solicitacoes: solicitacoesJson
          .map(
            (item) =>
                SolicitacaoConcessao.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  String get titulo {
    final ano = anoReferencia == null ? '' : '/$anoReferencia';
    if (tipo == TipoConcessao.ferias && periodo != null) {
      return '${tipo.label} - $periodoº período$ano';
    }
    if (tipo == TipoConcessao.licencaEleitoral) {
      return '${tipo.label} - ${TurnoEleitoral.fromPeriodo(periodo).label}$ano';
    }
    return '${tipo.label}$ano';
  }
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
