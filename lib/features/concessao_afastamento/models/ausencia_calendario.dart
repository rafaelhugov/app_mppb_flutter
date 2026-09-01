import 'solicitacao_concessao.dart';
import 'tipo_ausencia.dart';

class AusenciaCalendario {
  final String id;
  final TipoAusencia tipo;
  final String descricao;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String? status;
  final String? observacao;

  const AusenciaCalendario({
    required this.id,
    required this.tipo,
    required this.descricao,
    required this.dataInicio,
    required this.dataFim,
    this.status,
    this.observacao,
  });

  factory AusenciaCalendario.fromJson(Map<String, dynamic> json) {
    return AusenciaCalendario(
      id: json['id']?.toString() ?? '',
      tipo: TipoAusencia.fromJson(json['tipo'] as String?),
      descricao: (json['descricao'] as String?)?.trim().isNotEmpty == true
          ? json['descricao'] as String
          : TipoAusencia.fromJson(json['tipo'] as String?).label,
      dataInicio: DateTime.parse(json['dataInicio'] as String),
      dataFim: DateTime.parse(json['dataFim'] as String),
      status: json['status'] as String?,
      observacao: json['observacao'] as String?,
    );
  }

  DateTime get inicioNormalizado => normalizarData(dataInicio);
  DateTime get fimNormalizado => normalizarData(dataFim);

  bool get periodoValido => !fimNormalizado.isBefore(inicioNormalizado);

  bool intersectaMes(DateTime mes) {
    final primeiroDia = DateTime(mes.year, mes.month);
    final ultimoDia = DateTime(mes.year, mes.month + 1, 0);
    return !inicioNormalizado.isAfter(ultimoDia) &&
        !fimNormalizado.isBefore(primeiroDia);
  }
}
