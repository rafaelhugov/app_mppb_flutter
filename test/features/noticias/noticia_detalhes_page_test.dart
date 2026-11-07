import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mppb_flutter/features/noticias/models/noticia.dart';
import 'package:app_mppb_flutter/features/noticias/ui/noticia_detalhes_page.dart';

const List<int> _kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl ||
        invocation.memberName == #openUrl ||
        invocation.memberName == #get ||
        invocation.memberName == #open) {
      return Future.value(_MockHttpClientRequest());
    }
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(_MockHttpClientResponse());
    }
    return null;
  }
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  group('NoticiaDetalhesPage', () {
    final noticiaExemplo = Noticia(
      chaveExterna: 'noticia-100',
      titulo: 'MPPB promove seminário sobre Direitos Humanos e Cidadania',
      resumo:
          'O Ministério Público da Paraíba realizou nesta sexta-feira um importante seminário.\n\nO evento reuniu membros, servidores e a sociedade civil para debater avanços sociais e novos projetos para o estado.',
      link: 'https://www.mppb.mp.br/noticias/seminario-direitos-humanos',
      categoria: 'Institucional',
      imagemUrl: 'https://www.mppb.mp.br/imagens/seminario.jpg',
      dataPublicacao: '2026-11-06',
    );

    testWidgets('exibe titulo, categoria, data e paragrafos na pagina propria',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: NoticiaDetalhesPage(noticia: noticiaExemplo),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notícia'), findsOneWidget);
      expect(
        find.text('MPPB promove seminário sobre Direitos Humanos e Cidadania'),
        findsOneWidget,
      );
      expect(find.text('INSTITUCIONAL'), findsOneWidget);
      expect(find.text('06/11/2026'), findsOneWidget);
      expect(
        find.textContaining('O Ministério Público da Paraíba realizou'),
        findsOneWidget,
      );
      expect(
        find.textContaining('O evento reuniu membros, servidores'),
        findsOneWidget,
      );
      expect(find.text('Ler matéria completa no portal'), findsOneWidget);
      expect(find.text('Compartilhar'), findsWidgets);
    });

    testWidgets(
        'abre visualizador de imagem em tela cheia ao tocar na foto de capa',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: NoticiaDetalhesPage(noticia: noticiaExemplo),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Encontra a imagem de capa e clica nela
      final heroImageFinder = find.byType(InkWell).first;
      await tester.tap(heroImageFinder);
      await tester.pumpAndSettle();

      // Confirma que abriu a página NoticiaImageViewerPage
      expect(find.byType(NoticiaImageViewerPage), findsOneWidget);
      expect(find.byIcon(Icons.rotate_90_degrees_cw_rounded), findsOneWidget);

      // Testa a rotação da imagem
      final rotateButton = find.byIcon(Icons.rotate_90_degrees_cw_rounded);
      await tester.tap(rotateButton);
      await tester.pumpAndSettle();

      // Confirma que o widget RotatedBox foi atualizado
      final rotatedBoxFinder = find.byType(RotatedBox);
      expect(rotatedBoxFinder, findsOneWidget);
      final rotatedBox = tester.widget<RotatedBox>(rotatedBoxFinder);
      expect(rotatedBox.quarterTurns, 1);
    });
  });
}
