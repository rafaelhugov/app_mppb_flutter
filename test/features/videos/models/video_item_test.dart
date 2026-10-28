import 'package:flutter_test/flutter_test.dart';
import 'package:app_mppb_flutter/features/videos/models/video_item.dart';
import 'package:app_mppb_flutter/features/videos/models/videos_response.dart';

void main() {
  group('VideoItem Model Tests', () {
    test('deve criar VideoItem a partir de json com campos corretos', () {
      final json = {
        'id': 'abc12345678',
        'titulo': '15ª Sessão Ordinária do CPJ',
        'descricao': 'Transmissão da sessão do colégio de procuradores',
        'link': 'https://www.youtube.com/watch?v=abc12345678',
        'thumbnailUrl': 'https://i.ytimg.com/vi/abc12345678/hqdefault.jpg',
        'dataPublicacao': '27/10/2026',
        'dataPublicacaoIso': '2026-10-27T01:57:13+00:00',
        'tipo': 'SESSAO_LIVE',
        'isAoVivo': false,
      };

      final video = VideoItem.fromJson(json);

      expect(video.id, 'abc12345678');
      expect(video.titulo, '15ª Sessão Ordinária do CPJ');
      expect(video.isSessao, isTrue);
      expect(video.isInstitucional, isFalse);
      expect(video.isAoVivo, isFalse);
      expect(video.badgeLabel, 'SESSÃO / LIVE GRAVADA');
      expect(video.youtubeUrl, 'https://www.youtube.com/watch?v=abc12345678');
      expect(video.fallbackThumbnail, 'https://i.ytimg.com/vi/abc12345678/hqdefault.jpg');
    });

    test('deve tratar video ao vivo corretamente', () {
      final video = const VideoItem(
        id: 'live123',
        titulo: 'Transmissão Ao Vivo',
        tipo: 'AO_VIVO',
        isAoVivo: true,
      );

      expect(video.isAoVivo, isTrue);
      expect(video.badgeLabel, 'AO VIVO AGORA');
    });

    test('deve tratar video institucional corretamente', () {
      final video = const VideoItem(
        id: 'inst123',
        titulo: 'Campanha Outubro Rosa',
        tipo: 'INSTITUCIONAL',
        isAoVivo: false,
      );

      expect(video.isInstitucional, isTrue);
      expect(video.isSessao, isFalse);
      expect(video.badgeLabel, 'INSTITUCIONAL');
    });

    test('deve deserializar VideosResponse com liveAtiva e videos', () {
      final json = {
        'liveAtiva': {
          'id': 'liveActiveId',
          'titulo': 'Sessão Extraordinária Ao Vivo',
          'tipo': 'AO_VIVO',
          'isAoVivo': true,
        },
        'videos': [
          {
            'id': 'v1',
            'titulo': 'Vídeo 1',
            'tipo': 'INSTITUCIONAL',
          },
          {
            'id': 'v2',
            'titulo': 'Sessão 2',
            'tipo': 'SESSAO_LIVE',
          }
        ],
        'total': 2,
      };

      final response = VideosResponse.fromJson(json);

      expect(response.liveAtiva, isNotNull);
      expect(response.liveAtiva!.id, 'liveActiveId');
      expect(response.videos.length, 2);
      expect(response.total, 2);
    });
  });
}
