class SolicitacaoFerias {
  final int id;
  final String tipo;
  final String tipoExtenso;
  final String status;
  final String statusExtenso;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String? justificativa;

  SolicitacaoFerias({
    required this.id,
    required this.tipo,
    required this.tipoExtenso,
    required this.status,
    required this.statusExtenso,
    required this.dataInicio,
    required this.dataFim,
    this.justificativa,
  });

  factory SolicitacaoFerias.fromJson(Map<String, dynamic> json) {
    return SolicitacaoFerias(
      id: json['id'] as int,
      tipo: json['tipo'] as String,
      tipoExtenso: json['tipoExtenso'] as String,
      status: json['status'] as String,
      statusExtenso: json['statusExtenso'] as String,
      dataInicio: DateTime.parse(json['dataInicio'] as String),
      dataFim: DateTime.parse(json['dataFim'] as String),
      justificativa: json['justificativa'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'tipoExtenso': tipoExtenso,
      'status': status,
      'statusExtenso': statusExtenso,
      'dataInicio': dataInicio.toIso8601String(),
      'dataFim': dataFim.toIso8601String(),
      'justificativa': justificativa,
    };
  }
}
