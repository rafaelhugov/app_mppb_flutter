enum CategoriaAnexo {
  imagem('IMAGEM'),
  video('VIDEO'),
  audio('AUDIO'),
  documento('DOCUMENTO');

  const CategoriaAnexo(this.apiValue);
  final String apiValue;

  static CategoriaAnexo fromApi(String? value) {
    final normalized = value?.trim().toUpperCase();
    return CategoriaAnexo.values.firstWhere(
      (e) => e.apiValue == normalized,
      orElse: () => CategoriaAnexo.documento,
    );
  }
}

class MensagemAnexoModel {
  const MensagemAnexoModel({
    required this.id,
    required this.categoria,
    required this.nomeOriginal,
    required this.mimeType,
    required this.tamanhoBytes,
    this.duracaoSegundos,
    this.possuiThumbnail = false,
  });

  final int id;
  final CategoriaAnexo categoria;
  final String nomeOriginal;
  final String mimeType;
  final int tamanhoBytes;
  final int? duracaoSegundos;
  final bool possuiThumbnail;

  factory MensagemAnexoModel.fromJson(Map<String, dynamic> json) {
    return MensagemAnexoModel(
      id: (json['id'] as num).toInt(),
      categoria: CategoriaAnexo.fromApi(json['categoria'] as String?),
      nomeOriginal: (json['nomeOriginal'] as String?) ?? 'anexo',
      mimeType: (json['mimeType'] as String?) ?? 'application/octet-stream',
      tamanhoBytes: (json['tamanhoBytes'] as num?)?.toInt() ?? 0,
      duracaoSegundos: (json['duracaoSegundos'] as num?)?.toInt(),
      possuiThumbnail: (json['possuiThumbnail'] as bool?) ?? false,
    );
  }

  String get tamanhoFormatado {
    if (tamanhoBytes < 1024) return '$tamanhoBytes B';
    if (tamanhoBytes < 1024 * 1024) {
      return '${(tamanhoBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(tamanhoBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

