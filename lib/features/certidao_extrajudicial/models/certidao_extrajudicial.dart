class CertidaoExtrajudicial {
  const CertidaoExtrajudicial({
    this.id,
    this.codigoVerificador,
    this.tipoDocumento,
    this.documentoFormatado,
    this.nome,
    this.data,
    this.negativa,
    this.status,
    this.protocolos = const [],
  });

  final int? id;
  final String? codigoVerificador;
  final String? tipoDocumento;
  final String? documentoFormatado;
  final String? nome;
  final DateTime? data;
  final bool? negativa;
  final String? status;
  final List<ProtocoloCertidao> protocolos;

  factory CertidaoExtrajudicial.fromJson(Map<String, dynamic> json) {
    return CertidaoExtrajudicial(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      codigoVerificador: json['codigoVerificador']?.toString(),
      tipoDocumento: json['tipoDocumento']?.toString(),
      documentoFormatado: json['documentoFormatado']?.toString(),
      nome: json['nome']?.toString(),
      data: json['data'] != null
          ? DateTime.tryParse(json['data'].toString())
          : null,
      negativa: json['negativa'] as bool?,
      status: json['status']?.toString(),
      protocolos: (json['protocolos'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProtocoloCertidao.fromJson)
          .toList(),
    );
  }
}

class ProtocoloCertidao {
  const ProtocoloCertidao({this.numero, this.classe, this.assunto});

  final String? numero;
  final String? classe;
  final String? assunto;

  factory ProtocoloCertidao.fromJson(Map<String, dynamic> json) {
    return ProtocoloCertidao(
      numero: json['numero']?.toString(),
      classe: json['classe']?.toString(),
      assunto: json['assunto']?.toString(),
    );
  }
}
