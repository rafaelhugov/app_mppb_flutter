class DiarioOficial {
  final String id;
  final String numeroEdicao;
  final DateTime? dataPublicacao;
  final String idArquivo;

  DiarioOficial({
    required this.id,
    required this.numeroEdicao,
    this.dataPublicacao,
    required this.idArquivo,
  });

  factory DiarioOficial.fromJson(Map<String, dynamic> json) {
    return DiarioOficial(
      id: json['id'].toString(),
      numeroEdicao: json['numeroEdicao'].toString(),
      dataPublicacao: json['dataPublicacao'] != null 
          ? DateTime.parse(json['dataPublicacao']) 
          : null,
      idArquivo: json['idArquivo'].toString(),
    );
  }
}
