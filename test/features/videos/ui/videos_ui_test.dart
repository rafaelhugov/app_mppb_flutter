import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_mppb_flutter/features/videos/models/video_item.dart';
import 'package:app_mppb_flutter/features/videos/providers/videos_provider.dart';
import 'package:app_mppb_flutter/features/videos/ui/widgets/live_banner_card.dart';
import 'package:app_mppb_flutter/features/videos/ui/videos_page.dart';

class FakeVideosNotifier extends Notifier<VideosState> implements VideosNotifier {
  final VideosState initialState;

  FakeVideosNotifier(this.initialState);

  @override
  VideosState build() => initialState;

  @override
  Future<void> fetchVideos({bool isUserRefresh = false}) async {}

  @override
  void setSearchTerm(String term) {}

  @override
  void setFiltro(TipoVideoFiltro filtro) {}
}

void main() {
  group('LiveBannerCard Widget Tests', () {
    testWidgets('deve renderizar LiveBannerCard com título e badge AO VIVO', (
      tester,
    ) async {
      const live = VideoItem(
        id: 'live123',
        titulo: 'Sessão Extraordinária do Colégio de Procuradores',
        tipo: 'AO_VIVO',
        isAoVivo: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiveBannerCard(liveVideo: live),
          ),
        ),
      );

      expect(find.text('AO VIVO AGORA'), findsOneWidget);
      expect(find.text('TV MPPB'), findsOneWidget);
      expect(find.text('Sessão Extraordinária do Colégio de Procuradores'), findsOneWidget);
      expect(find.text('Assistir'), findsOneWidget);
      expect(find.byIcon(Icons.sensors_rounded), findsOneWidget);
    });

    testWidgets('deve renderizar VideosPage com canal e abas estilo YouTube', (
      tester,
    ) async {
      const v1 = VideoItem(
        id: 'vid1',
        titulo: 'Vídeo Institucional MPPB',
        duracao: '12:30',
        visualizacoes: '350 visualizações',
        tipo: 'INSTITUCIONAL',
      );

      final state = const VideosState(
        isLoading: false,
        videos: [v1],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            videosProvider.overrideWith(() => FakeVideosNotifier(state)),
          ],
          child: const MaterialApp(
            home: VideosPage(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Canal MPPB'), findsWidgets);
      expect(find.text('Todos (1)'), findsOneWidget);
      expect(find.text('Vídeos (1)'), findsOneWidget);
      expect(find.text('Ao Vivo & Sessões (0)'), findsOneWidget);
      expect(find.text('Vídeo Institucional MPPB'), findsOneWidget);
      expect(find.text('12:30'), findsOneWidget);
    });
  });
}
