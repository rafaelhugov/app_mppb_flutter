class Competencia {
  final int mes;
  final int ano;

  Competencia({required this.mes, required this.ano});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Competencia && runtimeType == other.runtimeType && mes == other.mes && ano == other.ano;

  @override
  int get hashCode => mes.hashCode ^ ano.hashCode;
}

class LancamentoContracheque {
  final String codigo;
  final String descricao;
  final double valor;
  final String tipo; // 'V' para vantagem/provento, 'D' para desconto

  LancamentoContracheque({
    required this.codigo,
    required this.descricao,
    required this.valor,
    required this.tipo,
  });

  factory LancamentoContracheque.fromJson(Map<String, dynamic> json) {
    return LancamentoContracheque(
      codigo: json['codigo'].toString(),
      descricao: json['descricao'] as String,
      valor: (json['valor'] as num).toDouble(),
      tipo: json['tipo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'descricao': descricao,
      'valor': valor,
      'tipo': tipo,
    };
  }
}

class ContraCheque {
  final String id;
  final int mes;
  final int ano;
  final double valorBruto;
  final double totalDescontos;
  final double valorLiquido;
  final DateTime? dataPagamento;
  final String? linkPdf;
  final List<LancamentoContracheque> lancamentos;

  ContraCheque({
    required this.id,
    required this.mes,
    required this.ano,
    required this.valorBruto,
    required this.totalDescontos,
    required this.valorLiquido,
    this.dataPagamento,
    this.linkPdf,
    this.lancamentos = const [],
  });

  factory ContraCheque.fromJson(Map<String, dynamic> json) {
    return ContraCheque(
      id: json['id'].toString(),
      mes: json['mes'] as int,
      ano: json['ano'] as int,
      valorBruto: (json['valorBruto'] as num).toDouble(),
      totalDescontos: (json['totalDescontos'] as num).toDouble(),
      valorLiquido: (json['valorLiquido'] as num).toDouble(),
      dataPagamento: json['dataPagamento'] != null 
          ? DateTime.parse(json['dataPagamento']) 
          : null,
      linkPdf: json['linkPdf'] as String?,
      lancamentos: (json['lancamentos'] as List<dynamic>?)
              ?.map((e) => LancamentoContracheque.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mes': mes,
      'ano': ano,
      'valorBruto': valorBruto,
      'totalDescontos': totalDescontos,
      'valorLiquido': valorLiquido,
      'dataPagamento': dataPagamento?.toIso8601String(),
      'linkPdf': linkPdf,
      'lancamentos': lancamentos.map((e) => e.toJson()).toList(),
    };
  }
}
