class PreferenciasNotificacao {
  final bool pushNoticias;
  final bool pushDesignacoes;
  final bool pushContracheques;
  final bool pushPagamentos;
  final bool pushAfastamentos;
  final bool centralNoticias;
  final bool centralDesignacoes;
  final bool centralContracheques;
  final bool centralPagamentos;
  final bool centralAfastamentos;

  const PreferenciasNotificacao({
    this.pushNoticias = true,
    this.pushDesignacoes = true,
    this.pushContracheques = true,
    this.pushPagamentos = true,
    this.pushAfastamentos = true,
    this.centralNoticias = true,
    this.centralDesignacoes = true,
    this.centralContracheques = true,
    this.centralPagamentos = true,
    this.centralAfastamentos = true,
  });

  factory PreferenciasNotificacao.fromJson(Map<String, dynamic> json) {
    return PreferenciasNotificacao(
      // A leitura do formato anterior preserva as escolhas já salvas até que
      // todos os ambientes do serviço recebam a migração dos novos canais.
      pushNoticias: _value(json, 'pushNoticias', 'noticias'),
      pushDesignacoes: _value(json, 'pushDesignacoes', 'designacoes'),
      pushContracheques: _value(json, 'pushContracheques', 'contracheques'),
      pushPagamentos: _value(json, 'pushPagamentos', 'pagamentos'),
      pushAfastamentos: _value(json, 'pushAfastamentos', 'afastamentos'),
      centralNoticias: _value(json, 'centralNoticias', 'noticias'),
      centralDesignacoes: _value(json, 'centralDesignacoes', 'designacoes'),
      centralContracheques: _value(
        json,
        'centralContracheques',
        'contracheques',
      ),
      centralPagamentos: _value(json, 'centralPagamentos', 'pagamentos'),
      centralAfastamentos: _value(json, 'centralAfastamentos', 'afastamentos'),
    );
  }

  PreferenciasNotificacao copyWith({
    bool? pushNoticias,
    bool? pushDesignacoes,
    bool? pushContracheques,
    bool? pushPagamentos,
    bool? pushAfastamentos,
    bool? centralNoticias,
    bool? centralDesignacoes,
    bool? centralContracheques,
    bool? centralPagamentos,
    bool? centralAfastamentos,
  }) {
    return PreferenciasNotificacao(
      pushNoticias: pushNoticias ?? this.pushNoticias,
      pushDesignacoes: pushDesignacoes ?? this.pushDesignacoes,
      pushContracheques: pushContracheques ?? this.pushContracheques,
      pushPagamentos: pushPagamentos ?? this.pushPagamentos,
      pushAfastamentos: pushAfastamentos ?? this.pushAfastamentos,
      centralNoticias: centralNoticias ?? this.centralNoticias,
      centralDesignacoes: centralDesignacoes ?? this.centralDesignacoes,
      centralContracheques: centralContracheques ?? this.centralContracheques,
      centralPagamentos: centralPagamentos ?? this.centralPagamentos,
      centralAfastamentos: centralAfastamentos ?? this.centralAfastamentos,
    );
  }

  Map<String, dynamic> toJson() => {
    'pushNoticias': pushNoticias,
    'pushDesignacoes': pushDesignacoes,
    'pushContracheques': pushContracheques,
    'pushPagamentos': pushPagamentos,
    'pushAfastamentos': pushAfastamentos,
    'centralNoticias': centralNoticias,
    'centralDesignacoes': centralDesignacoes,
    'centralContracheques': centralContracheques,
    'centralPagamentos': centralPagamentos,
    'centralAfastamentos': centralAfastamentos,
  };

  static bool _value(Map<String, dynamic> json, String key, String legacyKey) {
    return json[key] as bool? ?? json[legacyKey] as bool? ?? true;
  }
}
