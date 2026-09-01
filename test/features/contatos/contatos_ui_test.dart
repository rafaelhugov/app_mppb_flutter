import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mppb_flutter/features/public/ui/public_dashboard_page.dart';
import 'package:app_mppb_flutter/features/dashboard/ui/dashboard_page.dart';
import 'package:app_mppb_flutter/features/noticias/providers/noticia_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockNoticiaNotifier extends Notifier<NoticiaState>
    implements NoticiaNotifier {
  @override
  NoticiaState build() {
    return NoticiaState();
  }

  @override
  Future<void> fetchNoticias() async {}

  @override
  void setSearchTerm(String term) {}

  @override
  void setPage(int page) {}
}

void main() {
  group('Home Publica - Testes', () {
    testWidgets('Deve exibir o card de Contatos na grade de serviços', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            noticiaProvider.overrideWith(() => MockNoticiaNotifier()),
          ],
          child: const MaterialApp(home: PublicDashboardPage()),
        ),
      );
      await tester.pump();

      // O texto "Contatos" no label do card e "Atendimento" no subtitle
      expect(find.text('Contatos'), findsOneWidget);
      expect(find.text('Atendimento'), findsOneWidget);

      // Secao Institucional (Fale com o MPPB)
      expect(find.text('Ouvidoria'), findsWidgets);
    });
  });

  group('Home Autenticada - Testes', () {
    testWidgets(
      'NÃO deve exibir o card de Contatos na grade de serviços, mas deve exibir a seção no rodapé',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              noticiaProvider.overrideWith(() => MockNoticiaNotifier()),
            ],
            child: const MaterialApp(home: DashboardPage()),
          ),
        );
        await tester.pump();

        // Na grade, não deve haver o card de "Atendimento" (isso testa a ausência na grade)
        // Como a seção institucional tb usa a palavra "Contatos" na página interna,
        // buscamos especificamente o subtitle "Atendimento" do card.
        expect(find.text('Atendimento'), findsNothing);
        expect(find.text('Serviços ao cidadão'), findsOneWidget);
        expect(find.text('Serviços internos'), findsOneWidget);
        expect(find.text('Certidão'), findsOneWidget);
        expect(find.text('Ouvidoria'), findsOneWidget);
        expect(find.text('Processos'), findsOneWidget);
        expect(find.text('Contracheque'), findsOneWidget);

        expect(find.text('Diário Oficial'), findsOneWidget);
        expect(find.text('Pagamentos'), findsOneWidget);
      },
    );
  });
}
