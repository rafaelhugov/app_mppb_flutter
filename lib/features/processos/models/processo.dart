class ProcessoResumo {
  final int? id;
  final String? numeroProcesso;
  final String? numeroOrigem;
  final String? classe;
  final String? promotoria;
  final String? assuntoPrincipal;
  final String? dataRegistro;
  final String? localizacaoAtual;
  final String? status;
  final String? interessado;

  ProcessoResumo({
    this.id,
    this.numeroProcesso,
    this.numeroOrigem,
    this.classe,
    this.promotoria,
    this.assuntoPrincipal,
    this.dataRegistro,
    this.localizacaoAtual,
    this.status,
    this.interessado,
  });

  factory ProcessoResumo.fromJson(Map<String, dynamic> json) {
    return ProcessoResumo(
      id: json['id'],
      numeroProcesso: json['numeroProcesso'],
      numeroOrigem: json['numeroOrigem'],
      classe: json['classe'],
      promotoria: json['promotoria'],
      assuntoPrincipal: json['assuntoPrincipal'],
      dataRegistro: json['dataRegistro'],
      localizacaoAtual: json['localizacaoAtual'],
      status: json['status'],
      interessado: json['interessado'],
    );
  }
}

class ProcessoFiltroOption {
  final String id;
  final String label;

  const ProcessoFiltroOption({
    required this.id,
    required this.label,
  });

  factory ProcessoFiltroOption.fromJson(Map<String, dynamic> json) {
    return ProcessoFiltroOption(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

class ProcessoFiltros {
  final List<ProcessoFiltroOption> comarcas;
  final List<ProcessoFiltroOption> classes;
  final List<ProcessoFiltroOption> tiposAtividade;
  final List<ProcessoFiltroOption> status;

  const ProcessoFiltros({
    this.comarcas = const [],
    this.classes = const [],
    this.tiposAtividade = const [],
    this.status = const [],
  });

  factory ProcessoFiltros.fromJson(Map<String, dynamic> json) {
    return ProcessoFiltros(
      comarcas: _parseOptions(json['comarcas']),
      classes: _parseOptions(json['classes']),
      tiposAtividade: _parseOptions(json['tiposAtividade']),
      status: _parseOptions(json['status']),
    );
  }

  static List<ProcessoFiltroOption> _parseOptions(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(ProcessoFiltroOption.fromJson)
        .where((item) => item.id.isNotEmpty && item.label.isNotEmpty)
        .toList(growable: false);
  }
}

class Movimentacao {
  final String? tipo;
  final String? data;
  final String? complemento;

  Movimentacao({this.tipo, this.data, this.complemento});

  factory Movimentacao.fromJson(Map<String, dynamic> json) {
    return Movimentacao(
      tipo: json['tipo'],
      data: json['data'],
      complemento: json['complemento'],
    );
  }
}

class Interessado {
  final String? nome;
  final String? nomeSocial;
  final String? tipoPessoa;
  final String? tipoParte;
  final String? documento;

  Interessado({
    this.nome,
    this.nomeSocial,
    this.tipoPessoa,
    this.tipoParte,
    this.documento,
  });

  factory Interessado.fromJson(Map<String, dynamic> json) {
    return Interessado(
      nome: json['nome'],
      nomeSocial: json['nomeSocial'],
      tipoPessoa: json['tipoPessoa'],
      tipoParte: json['tipoParte'],
      documento: json['documento'],
    );
  }
}

class ProcessoDetalhe extends ProcessoResumo {
  final String? textoInformado;
  final List<Movimentacao> movimentos;
  final List<Interessado> interessados;

  ProcessoDetalhe({
    super.id,
    super.numeroProcesso,
    super.numeroOrigem,
    super.classe,
    super.promotoria,
    super.assuntoPrincipal,
    super.dataRegistro,
    super.localizacaoAtual,
    super.status,
    super.interessado,
    this.textoInformado,
    this.movimentos = const [],
    this.interessados = const [],
  });

  factory ProcessoDetalhe.fromJson(Map<String, dynamic> json) {
    return ProcessoDetalhe(
      id: json['id'],
      numeroProcesso: json['numeroProcesso'],
      numeroOrigem: json['numeroOrigem'],
      classe: json['classe'],
      promotoria: json['promotoria'],
      assuntoPrincipal: json['assuntoPrincipal'],
      dataRegistro: json['dataRegistro'],
      localizacaoAtual: json['localizacaoAtual'],
      status: json['status'],
      interessado: json['interessado'],
      textoInformado: json['textoInformado'],
      movimentos: (json['movimentos'] as List<dynamic>?)
              ?.map((e) => Movimentacao.fromJson(e))
              .toList() ??
          [],
      interessados: (json['interessados'] as List<dynamic>?)
              ?.map((e) => Interessado.fromJson(e))
              .toList() ??
          [],
    );
  }
}
