import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_mppb_flutter/features/videos/models/video_item.dart';
import 'package:app_mppb_flutter/features/videos/providers/videos_provider.dart';
import 'package:app_mppb_flutter/features/videos/ui/widgets/live_banner_card.dart';

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
  });
}
