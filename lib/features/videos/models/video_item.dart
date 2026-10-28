import 'package:flutter/material.dart';

enum TipoVideoFiltro {
  todos,
  sessoes,
  institucionais,
}

class VideoItem {
  final String id;
  final String titulo;
  final String? descricao;
  final String? link;
  final String? thumbnailUrl;
  final String? dataPublicacao;
  final String? dataPublicacaoIso;
  final String tipo; // AO_VIVO, SESSAO_LIVE, INSTITUCIONAL
  final bool isAoVivo;

  const VideoItem({
    required this.id,
    required this.titulo,
    this.descricao,
    this.link,
    this.thumbnailUrl,
    this.dataPublicacao,
    this.dataPublicacaoIso,
    this.tipo = 'INSTITUCIONAL',
    this.isAoVivo = false,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] as String? ?? '',
      titulo: json['titulo'] as String? ?? '',
      descricao: json['descricao'] as String?,
      link: json['link'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      dataPublicacao: json['dataPublicacao'] as String?,
      dataPublicacaoIso: json['dataPublicacaoIso'] as String?,
      tipo: json['tipo'] as String? ?? 'INSTITUCIONAL',
      isAoVivo: json['isAoVivo'] as bool? ?? false,
    );
  }

  bool get isSessao => tipo == 'SESSAO_LIVE' || tipo == 'AO_VIVO';
  bool get isInstitucional => tipo == 'INSTITUCIONAL';

  String get youtubeUrl =>
      link?.isNotEmpty == true ? link! : 'https://www.youtube.com/watch?v=$id';

  String get fallbackThumbnail =>
      thumbnailUrl?.isNotEmpty == true
          ? thumbnailUrl!
          : 'https://i.ytimg.com/vi/$id/hqdefault.jpg';

  String get badgeLabel {
    if (isAoVivo) return 'AO VIVO AGORA';
    if (tipo == 'SESSAO_LIVE') return 'SESSÃO / LIVE GRAVADA';
    return 'INSTITUCIONAL';
  }

  Color get badgeColor {
    if (isAoVivo) return const Color(0xFFD62828); // Vermelho vibrante
    if (tipo == 'SESSAO_LIVE') return const Color(0xFF1E3A8A); // Azul colegiado
    return const Color(0xFF0F766E); // Teal institucional elegante
  }

  Color get badgeBackgroundColor {
    if (isAoVivo) return const Color(0x1FD62828);
    if (tipo == 'SESSAO_LIVE') return const Color(0x1F1E3A8A);
    return const Color(0x1F0F766E);
  }

  IconData get badgeIcon {
    if (isAoVivo) return Icons.sensors_rounded;
    if (tipo == 'SESSAO_LIVE') return Icons.gavel_rounded;
    return Icons.videocam_rounded;
  }
}
