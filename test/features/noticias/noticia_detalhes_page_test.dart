import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mppb_flutter/features/noticias/models/noticia.dart';
import 'package:app_mppb_flutter/features/noticias/ui/noticia_detalhes_page.dart';

void main() {
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
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: NoticiaDetalhesPage(noticia: noticiaExemplo),
          ),
        ),
      );

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
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: NoticiaDetalhesPage(noticia: noticiaExemplo),
          ),
        ),
      );

      // Encontra a imagem de capa e clica nela
      final heroImageFinder = find.byType(InkWell).first;
      await tester.tap(heroImageFinder);
      await tester.pumpAndSettle();

      // Confirma que abriu a página NoticiaImageViewerPage
      expect(find.byType(NoticiaImageViewerPage), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byIcon(Icons.rotate_90_degrees_cw_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(
        find.text(noticiaExemplo.titulo),
        findsOneWidget,
      );

      // Testa a rotação da imagem ao clicar no botão
      final rotateButton = find.byIcon(Icons.rotate_90_degrees_cw_rounded);
      await tester.tap(rotateButton);
      await tester.pumpAndSettle();

      // Verifica se o RotatedBox tem quarterTurns = 1
      final rotatedBox = tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 1);

      // Clica novamente: quarterTurns = 2
      await tester.tap(rotateButton);
      await tester.pumpAndSettle();
      final rotatedBox2 = tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox2.quarterTurns, 2);

      // Botão de restaurar rotação deve aparecer
      expect(find.byIcon(Icons.restore_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.restore_rounded));
      await tester.pumpAndSettle();
      final rotatedBoxRestored = tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBoxRestored.quarterTurns, 0);

      // Fecha o visualizador
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(NoticiaImageViewerPage), findsNothing);
      expect(find.byType(NoticiaDetalhesPage), findsOneWidget);
    });
  });
}
