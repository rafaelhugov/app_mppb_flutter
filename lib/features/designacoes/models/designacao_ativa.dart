class DesignacoesAtivasResponse {
  final String tipoUsuario;
  final List<DesignacaoAtiva> designacoes;

  const DesignacoesAtivasResponse({
    required this.tipoUsuario,
    required this.designacoes,
  });

  factory DesignacoesAtivasResponse.fromJson(Map<String, dynamic> json) {
    final data = json['designacoes'] as List<dynamic>? ?? [];
    return DesignacoesAtivasResponse(
      tipoUsuario: json['tipoUsuario'] as String? ?? 'INDEFINIDO',
      designacoes: data
          .map((item) => DesignacaoAtiva.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DesignacaoAtiva {
  final int id;
  final String tipoCodigo;
  final String tipoDescricao;
  final String titulo;
  final String? subtitulo;
  final String? orgao;
  final String? funcao;
  final DateTime? dataInicial;
  final DateTime? dataFinal;
  final String? ato;
  final DateTime? dataPublicacao;

  const DesignacaoAtiva({
    required this.id,
    required this.tipoCodigo,
    required this.tipoDescricao,
    required this.titulo,
    this.subtitulo,
    this.orgao,
    this.funcao,
    this.dataInicial,
    this.dataFinal,
    this.ato,
    this.dataPublicacao,
  });

  factory DesignacaoAtiva.fromJson(Map<String, dynamic> json) {
    final ato = _technicalAct(json['ato']);
    return DesignacaoAtiva(
      id: (json['id'] as num?)?.toInt() ?? 0,
      tipoCodigo: json['tipoCodigo'] as String? ?? '',
      tipoDescricao: json['tipoDescricao'] as String? ?? 'Designação',
      titulo: json['titulo'] as String? ?? 'Designação',
      subtitulo: json['subtitulo'] as String?,
      orgao: json['orgao'] as String?,
      funcao: json['funcao'] as String?,
      dataInicial: _date(json['dataInicial']),
      dataFinal: _date(json['dataFinal']),
      ato: ato,
      dataPublicacao: ato == null && _startsWithIni(json['ato'])
          ? null
          : _date(json['dataPublicacao']),
    );
  }

  String get periodo {
    final inicio = formatDate(dataInicial);
    final fim = formatDate(dataFinal);
    if (inicio == null && fim == null) return '';
    if (inicio != null && fim != null) return '$inicio até $fim';
    if (inicio != null) return 'Desde $inicio';
    return 'Até $fim';
  }

  static DateTime? _date(Object? value) {
    if (value == null || value.toString().isBlank) return null;
    return DateTime.tryParse(value.toString());
  }

  static String? _technicalAct(Object? value) {
    if (value == null || value.toString().isBlank) return null;
    final text = value.toString().trim();
    return _startsWithIni(text) ? null : text;
  }

  static bool _startsWithIni(Object? value) {
    return value != null &&
        value.toString().trim().toUpperCase().startsWith('INI_');
  }

  static String? formatDate(DateTime? date) {
    if (date == null) return null;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

extension on String {
  bool get isBlank => trim().isEmpty;
}
