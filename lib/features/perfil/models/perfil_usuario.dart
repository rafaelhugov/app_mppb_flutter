class PerfilUsuario {
  final String? login;
  final String? nome;
  final String? matricula;
  final String? tipoCargo;
  final String? cargo;
  final String? tituloCargo;
  final String? especialidade;
  final String? situacao;
  final String? dataPosse;
  final String? dataAdmissao;
  final String? dataExercicio;
  final String? email;
  final String? telefone;
  final String? celular;
  final String? setorNome;
  final String? setorSigla;
  final String? orgaoNome;
  final String? orgaoSigla;
  final String? fotoUrl;

  const PerfilUsuario({
    this.login,
    this.nome,
    this.matricula,
    this.tipoCargo,
    this.cargo,
    this.tituloCargo,
    this.especialidade,
    this.situacao,
    this.dataPosse,
    this.dataAdmissao,
    this.dataExercicio,
    this.email,
    this.telefone,
    this.celular,
    this.setorNome,
    this.setorSigla,
    this.orgaoNome,
    this.orgaoSigla,
    this.fotoUrl,
  });

  factory PerfilUsuario.fromJson(Map<String, dynamic> json) {
    return PerfilUsuario(
      login: json['login'] as String?,
      nome: json['nome'] as String?,
      matricula: json['matricula']?.toString(),
      tipoCargo: json['tipoCargo'] as String?,
      cargo: json['cargo'] as String?,
      tituloCargo: json['tituloCargo'] as String?,
      especialidade: json['especialidade'] as String?,
      situacao: json['situacao'] as String?,
      dataPosse: json['dataPosse']?.toString(),
      dataAdmissao: json['dataAdmissao']?.toString(),
      dataExercicio: json['dataExercicio']?.toString(),
      email: json['email'] as String?,
      telefone: json['telefone'] as String?,
      celular: json['celular'] as String?,
      setorNome: json['setorNome'] as String?,
      setorSigla: json['setorSigla'] as String?,
      orgaoNome: json['orgaoNome'] as String?,
      orgaoSigla: json['orgaoSigla'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
    );
  }

  PerfilUsuario copyWith({String? fotoUrl}) {
    return PerfilUsuario(
      login: login,
      nome: nome,
      matricula: matricula,
      tipoCargo: tipoCargo,
      cargo: cargo,
      tituloCargo: tituloCargo,
      especialidade: especialidade,
      situacao: situacao,
      dataPosse: dataPosse,
      dataAdmissao: dataAdmissao,
      dataExercicio: dataExercicio,
      email: email,
      telefone: telefone,
      celular: celular,
      setorNome: setorNome,
      setorSigla: setorSigla,
      orgaoNome: orgaoNome,
      orgaoSigla: orgaoSigla,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'nome': nome,
      'matricula': matricula,
      'tipoCargo': tipoCargo,
      'cargo': cargo,
      'tituloCargo': tituloCargo,
      'especialidade': especialidade,
      'situacao': situacao,
      'dataPosse': dataPosse,
      'dataAdmissao': dataAdmissao,
      'dataExercicio': dataExercicio,
      'email': email,
      'telefone': telefone,
      'celular': celular,
      'setorNome': setorNome,
      'setorSigla': setorSigla,
      'orgaoNome': orgaoNome,
      'orgaoSigla': orgaoSigla,
      'fotoUrl': fotoUrl,
    };
  }
}
