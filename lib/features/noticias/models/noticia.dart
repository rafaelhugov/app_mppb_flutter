class Noticia {
  final String? chaveExterna;
  final String titulo;
  final String? resumo;
  final String? link;
  final String? categoria;
  final String? imagemUrl;
  final String? dataPublicacao;

  Noticia({
    this.chaveExterna,
    required this.titulo,
    this.resumo,
    this.link,
    this.categoria,
    this.imagemUrl,
    this.dataPublicacao,
  });

  factory Noticia.fromJson(Map<String, dynamic> json) {
    return Noticia(
      chaveExterna: json['chaveExterna'],
      titulo: json['titulo'] ?? '',
      resumo: json['resumo'],
      link: json['link'],
      categoria: json['categoria'],
      imagemUrl: json['imagemUrl'],
      dataPublicacao: json['dataPublicacao'],
    );
  }
}
