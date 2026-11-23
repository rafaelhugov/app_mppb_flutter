import 'package:app_mppb_flutter/core/ui/widgets/services_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'ServicesBottomSheet exibe todos os atalhos públicos quando deslogado',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ServicesBottomSheet.show(context, false),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      for (final label in const [
        'Notícias',
        'TV MPPB',
        'Diário',
        'Certidão',
        'Processos',
        'Ouvidoria',
        'Contatos',
        'Área Restrita',
      ]) {
        expect(find.text(label), findsOneWidget);
      }

      expect(find.text('Mensagens'), findsNothing);
      expect(find.text('Pagamentos'), findsNothing);
    },
  );

  testWidgets(
    'ServicesBottomSheet exibe todos os atalhos logados incluindo Mensagens e Contatos',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ServicesBottomSheet.show(context, true),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      for (final label in const [
        'Notícias',
        'TV MPPB',
        'Diário',
        'Certidão',
        'Pagamentos',
        'Designações',
        'Processos',
        'Mensagens',
        'Contatos',
        'Perfil',
        'Ouvidoria',
      ]) {
        expect(find.text(label), findsOneWidget);
      }

      expect(find.text('Área Restrita'), findsNothing);
    },
  );
}
