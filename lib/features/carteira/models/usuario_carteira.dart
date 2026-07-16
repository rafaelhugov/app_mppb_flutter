class UsuarioCarteira {
  final String? foto;
  final String? nome;
  final String? cargo;
  final String? matricula;
  final String? cpf;
  final String? rg;
  final String? orgaoExp;
  final String? nascimento;
  final String? naturalidade;
  final String? nomePai;
  final String? nomeMae;
  final String? nomePgj;
  final String? md5;
  final String? tipoCargo;

  UsuarioCarteira({
    this.foto,
    this.nome,
    this.cargo,
    this.matricula,
    this.cpf,
    this.rg,
    this.orgaoExp,
    this.nascimento,
    this.naturalidade,
    this.nomePai,
    this.nomeMae,
    this.nomePgj,
    this.md5,
    this.tipoCargo,
  });

  factory UsuarioCarteira.fromJson(Map<String, dynamic> json) {
    return UsuarioCarteira(
      foto: json['foto'] as String?,
      nome: json['nome'] as String?,
      cargo: json['cargo'] as String?,
      matricula: json['matricula']?.toString(), // As vezes vem como int
      cpf: json['cpf']?.toString(),
      rg: json['rg']?.toString(),
      orgaoExp: json['orgaoExp'] as String?,
      nascimento: json['nascimento'] as String?,
      naturalidade: json['naturalidade'] as String?,
      nomePai: json['nomePai'] as String?,
      nomeMae: json['nomeMae'] as String?,
      nomePgj: json['nomePgj'] as String?,
      md5: json['md5'] as String?,
      tipoCargo: json['tipoCargo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foto': foto,
      'nome': nome,
      'cargo': cargo,
      'matricula': matricula,
      'cpf': cpf,
      'rg': rg,
      'orgaoExp': orgaoExp,
      'nascimento': nascimento,
      'naturalidade': naturalidade,
      'nomePai': nomePai,
      'nomeMae': nomeMae,
      'nomePgj': nomePgj,
      'md5': md5,
      'tipoCargo': tipoCargo,
    };
  }
}
