import 'package:flutter_test/flutter_test.dart';
import 'package:app_mppb_flutter/features/videos/models/video_item.dart';
import 'package:app_mppb_flutter/features/videos/providers/videos_provider.dart';

void main() {
  group('VideosState Tests', () {
    const v1 = VideoItem(
      id: '1',
      titulo: '15ª Sessão Ordinária do CPJ',
      descricao: 'Sessão solene de julgamento',
      tipo: 'SESSAO_LIVE',
    );

    const v2 = VideoItem(
      id: '2',
      titulo: 'Campanha de Conscientização',
      descricao: 'Informativo à população paraibana',
      tipo: 'INSTITUCIONAL',
    );

    const v3 = VideoItem(
      id: '3',
      titulo: 'Posse de Novos Promotores',
      descricao: 'Transmissão ao vivo gravada',
      tipo: 'SESSAO_LIVE',
    );

    test('deve filtrar todos os vídeos quando filtro for todos', () {
      final state = const VideosState(
        videos: [v1, v2, v3],
        filtroSelecionado: TipoVideoFiltro.todos,
      );

      expect(state.filteredVideos.length, 3);
      expect(state.sessoesCount, 2);
      expect(state.institucionaisCount, 1);
    });

    test('deve filtrar apenas sessões quando filtro for sessoes', () {
      final state = const VideosState(
        videos: [v1, v2, v3],
        filtroSelecionado: TipoVideoFiltro.sessoes,
      );

      final filtered = state.filteredVideos;
      expect(filtered.length, 2);
      expect(filtered.every((v) => v.isSessao), isTrue);
    });

    test('deve filtrar apenas institucionais quando filtro for institucionais', () {
      final state = const VideosState(
        videos: [v1, v2, v3],
        filtroSelecionado: TipoVideoFiltro.institucionais,
      );

      final filtered = state.filteredVideos;
      expect(filtered.length, 1);
      expect(filtered.first.id, '2');
    });

    test('deve filtrar por termo de busca ignorando maiúsculas e minúsculas', () {
      final state = const VideosState(
        videos: [v1, v2, v3],
        searchTerm: 'posse',
        filtroSelecionado: TipoVideoFiltro.todos,
      );

      final filtered = state.filteredVideos;
      expect(filtered.length, 1);
      expect(filtered.first.id, '3');
    });

    test('deve combinar busca por termo e filtro de categoria', () {
      final state = const VideosState(
        videos: [v1, v2, v3],
        searchTerm: 'Conscientização',
        filtroSelecionado: TipoVideoFiltro.sessoes, // Não deve achar pois é institucional
      );

      expect(state.filteredVideos.isEmpty, isTrue);
    });
  });
}
