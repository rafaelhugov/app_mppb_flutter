class OpcaoGrupoRhModel {
  const OpcaoGrupoRhModel({
    required this.id,
    required this.nome,
    required this.quantidadeAtivos,
  });

  final String id;
  final String nome;
  final int quantidadeAtivos;

  factory OpcaoGrupoRhModel.fromJson(Map<String, dynamic> json) {
    return OpcaoGrupoRhModel(
      id: (json['id'] ?? '').toString(),
      nome: (json['nome'] as String?) ?? '',
      quantidadeAtivos: (json['quantidadeAtivos'] as num?)?.toInt() ?? 0,
    );
  }
}

class CatalogoGruposRhModel {
  const CatalogoGruposRhModel({
    this.tiposCargo = const [],
    this.orgaos = const [],
    this.setores = const [],
    this.cargos = const [],
  });

  final List<OpcaoGrupoRhModel> tiposCargo;
  final List<OpcaoGrupoRhModel> orgaos;
  final List<OpcaoGrupoRhModel> setores;
  final List<OpcaoGrupoRhModel> cargos;

  factory CatalogoGruposRhModel.fromJson(Map<String, dynamic> json) {
    List<OpcaoGrupoRhModel> parseList(String key) {
      final raw = (json[key] as List<dynamic>?) ?? const [];
      return raw
          .map((e) => OpcaoGrupoRhModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return CatalogoGruposRhModel(
      tiposCargo: parseList('tiposCargo'),
      orgaos: parseList('orgaos'),
      setores: parseList('setores'),
      cargos: parseList('cargos'),
    );
  }
}

class GrupoPersonalizadoModel {
  const GrupoPersonalizadoModel({
    required this.id,
    required this.nome,
    this.descricao,
    this.ativo = true,
    required this.quantidadeMembros,
    this.matriculas = const [],
  });

  final int id;
  final String nome;
  final String? descricao;
  final bool ativo;
  final int quantidadeMembros;
  final List<String> matriculas;

  factory GrupoPersonalizadoModel.fromJson(Map<String, dynamic> json) {
    final matRaw = (json['matriculas'] as List<dynamic>?) ?? const [];
    return GrupoPersonalizadoModel(
      id: (json['id'] as num).toInt(),
      nome: (json['nome'] as String?) ?? '',
      descricao: json['descricao'] as String?,
      ativo: (json['ativo'] as bool?) ?? true,
      quantidadeMembros: (json['quantidadeMembros'] as num?)?.toInt() ?? matRaw.length,
      matriculas: matRaw.map((e) => e.toString()).toList(),
    );
  }
}

class DestinatarioRhModel {
  const DestinatarioRhModel({
    required this.matricula,
    required this.nome,
    this.setorNome,
    this.cargoNome,
    this.tipoCargo,
  });

  final String matricula;
  final String nome;
  final String? setorNome;
  final String? cargoNome;
  final String? tipoCargo;

  factory DestinatarioRhModel.fromJson(Map<String, dynamic> json) {
    return DestinatarioRhModel(
      matricula: (json['matricula'] as String?) ?? '',
      nome: (json['nome'] as String?) ?? '',
      setorNome: json['setorNome'] as String?,
      cargoNome: json['cargoNome'] as String?,
      tipoCargo: json['tipoCargo'] as String?,
    );
  }
}

