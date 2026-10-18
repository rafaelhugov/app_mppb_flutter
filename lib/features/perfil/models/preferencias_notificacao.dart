class PreferenciasNotificacao {
  final bool noticias;
  final bool designacoes;
  final bool contracheques;
  final bool pagamentos;
  final bool afastamentos;

  const PreferenciasNotificacao({
    this.noticias = true,
    this.designacoes = true,
    this.contracheques = true,
    this.pagamentos = true,
    this.afastamentos = true,
  });

  factory PreferenciasNotificacao.fromJson(Map<String, dynamic> json) {
    return PreferenciasNotificacao(
      noticias: json['noticias'] as bool? ?? true,
      designacoes: json['designacoes'] as bool? ?? true,
      contracheques: json['contracheques'] as bool? ?? true,
      pagamentos: json['pagamentos'] as bool? ?? true,
      afastamentos: json['afastamentos'] as bool? ?? true,
    );
  }

  PreferenciasNotificacao copyWith({
    bool? noticias,
    bool? designacoes,
    bool? contracheques,
    bool? pagamentos,
    bool? afastamentos,
  }) {
    return PreferenciasNotificacao(
      noticias: noticias ?? this.noticias,
      designacoes: designacoes ?? this.designacoes,
      contracheques: contracheques ?? this.contracheques,
      pagamentos: pagamentos ?? this.pagamentos,
      afastamentos: afastamentos ?? this.afastamentos,
    );
  }

  Map<String, dynamic> toJson() => {
    'noticias': noticias,
    'designacoes': designacoes,
    'contracheques': contracheques,
    'pagamentos': pagamentos,
    'afastamentos': afastamentos,
  };
}
