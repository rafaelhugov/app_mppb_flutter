class Pagamento {
  final String? nuProcesso;
  final String? dtPagamento;
  final String? dsModalidadePag;
  final double? vlBruto;
  final double? vlLiquido;
  final String? cdElemento;
  final String? descricaoElemento;
  final String? sigla;
  final String? documento;

  Pagamento({
    this.nuProcesso,
    this.dtPagamento,
    this.dsModalidadePag,
    this.vlBruto,
    this.vlLiquido,
    this.cdElemento,
    this.descricaoElemento,
    this.sigla,
    this.documento,
  });

  factory Pagamento.fromJson(Map<String, dynamic> json) {
    return Pagamento(
      nuProcesso: json['nuProcesso']?.toString(),
      dtPagamento: json['dtPagamento']?.toString(),
      dsModalidadePag: json['dsModalidadePag']?.toString(),
      vlBruto: json['vlBruto'] != null ? (json['vlBruto'] as num).toDouble() : null,
      vlLiquido: json['vlLiquido'] != null ? (json['vlLiquido'] as num).toDouble() : null,
      cdElemento: json['cdElemento']?.toString(),
      descricaoElemento: json['descricaoElemento']?.toString(),
      sigla: json['sigla']?.toString(),
      documento: json['documento']?.toString(),
    );
  }
}

class PagamentoResponse {
  final double totalBruto;
  final double totalLiquido;
  final int totalPagamentos;
  final List<Pagamento> pagamentos;

  PagamentoResponse({
    required this.totalBruto,
    required this.totalLiquido,
    required this.totalPagamentos,
    required this.pagamentos,
  });

  factory PagamentoResponse.fromJson(Map<String, dynamic> json) {
    return PagamentoResponse(
      totalBruto: json['totalBruto'] != null ? (json['totalBruto'] as num).toDouble() : 0.0,
      totalLiquido: json['totalLiquido'] != null ? (json['totalLiquido'] as num).toDouble() : 0.0,
      totalPagamentos: json['totalPagamentos'] as int? ?? 0,
      pagamentos: json['pagamentos'] != null
          ? (json['pagamentos'] as List).map((i) => Pagamento.fromJson(i as Map<String, dynamic>)).toList()
          : [],
    );
  }
}
