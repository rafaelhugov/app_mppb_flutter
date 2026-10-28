class PreferenciasNotificacao {
  final bool pushNoticias;
  final bool pushDesignacoes;
  final bool pushContracheques;
  final bool pushPagamentos;
  final bool pushAfastamentos;
  final bool pushLives;
  final bool centralNoticias;
  final bool centralDesignacoes;
  final bool centralContracheques;
  final bool centralPagamentos;
  final bool centralAfastamentos;
  final bool centralLives;

  const PreferenciasNotificacao({
    this.pushNoticias = true,
    this.pushDesignacoes = true,
    this.pushContracheques = true,
    this.pushPagamentos = true,
    this.pushAfastamentos = true,
    this.pushLives = true,
    this.centralNoticias = true,
    this.centralDesignacoes = true,
    this.centralContracheques = true,
    this.centralPagamentos = true,
    this.centralAfastamentos = true,
    this.centralLives = true,
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
      pushLives: _value(json, 'pushLives', 'lives'),
      centralNoticias: _value(json, 'centralNoticias', 'noticias'),
      centralDesignacoes: _value(json, 'centralDesignacoes', 'designacoes'),
      centralContracheques: _value(
        json,
        'centralContracheques',
        'contracheques',
      ),
      centralPagamentos: _value(json, 'centralPagamentos', 'pagamentos'),
      centralAfastamentos: _value(json, 'centralAfastamentos', 'afastamentos'),
      centralLives: _value(json, 'centralLives', 'lives'),
    );
  }

  PreferenciasNotificacao copyWith({
    bool? pushNoticias,
    bool? pushDesignacoes,
    bool? pushContracheques,
    bool? pushPagamentos,
    bool? pushAfastamentos,
    bool? pushLives,
    bool? centralNoticias,
    bool? centralDesignacoes,
    bool? centralContracheques,
    bool? centralPagamentos,
    bool? centralAfastamentos,
    bool? centralLives,
  }) {
    return PreferenciasNotificacao(
      pushNoticias: pushNoticias ?? this.pushNoticias,
      pushDesignacoes: pushDesignacoes ?? this.pushDesignacoes,
      pushContracheques: pushContracheques ?? this.pushContracheques,
      pushPagamentos: pushPagamentos ?? this.pushPagamentos,
      pushAfastamentos: pushAfastamentos ?? this.pushAfastamentos,
      pushLives: pushLives ?? this.pushLives,
      centralNoticias: centralNoticias ?? this.centralNoticias,
      centralDesignacoes: centralDesignacoes ?? this.centralDesignacoes,
      centralContracheques: centralContracheques ?? this.centralContracheques,
      centralPagamentos: centralPagamentos ?? this.centralPagamentos,
      centralAfastamentos: centralAfastamentos ?? this.centralAfastamentos,
      centralLives: centralLives ?? this.centralLives,
    );
  }

  /// Formato aceito pela API REST do servidor (estrito a 10 campos).
  Map<String, dynamic> toApiJson() => {
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

  /// Formato completo para persistência local no dispositivo.
  Map<String, dynamic> toJson() => {
    ...toApiJson(),
    'pushLives': pushLives,
    'centralLives': centralLives,
  };

  static bool _value(Map<String, dynamic> json, String key, String legacyKey) {
    return json[key] as bool? ?? json[legacyKey] as bool? ?? true;
  }
}
