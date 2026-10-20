import 'package:app_mppb_flutter/core/notifications/notification_center_provider.dart';
import 'package:app_mppb_flutter/core/ui/widgets/notification_center_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra notificacoes individuais e executa abertura do item', (
    tester,
  ) async {
    NotificationCenterItem? openedItem;
    const item = NotificationCenterItem(
      key: 'noticia:https://mppb.mp.br/noticia-1',
      type: NotificationCenterItemType.noticia,
      title: 'MPPB publica nova noticia',
      subtitle: 'Procuradoria-Geral - 08/09/2026',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationCenterContent(
            items: const [item],
            onClose: () {},
            onOpenItem: (value) => openedItem = value,
          ),
        ),
      ),
    );

    expect(find.text('Notificações'), findsOneWidget);
    expect(find.text('Notícias'), findsOneWidget);
    expect(find.text('MPPB publica nova noticia'), findsOneWidget);
    expect(find.text('Procuradoria-Geral - 08/09/2026'), findsOneWidget);

    await tester.tap(find.text('MPPB publica nova noticia'));
    await tester.pump();

    expect(openedItem?.key, item.key);
  });

  testWidgets('mostra estado vazio quando todas foram lidas', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationCenterContent(
            items: const [],
            onClose: () {},
            onOpenItem: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Nenhuma notificação nova'), findsOneWidget);
    expect(find.text('Notícias'), findsNothing);
    expect(find.text('Designações'), findsNothing);
  });

  testWidgets('limita previa do grupo e expande em ver todas', (tester) async {
    final items = List.generate(
      5,
      (index) => NotificationCenterItem(
        key: 'noticia:$index',
        type: NotificationCenterItemType.noticia,
        title: 'Noticia $index',
        subtitle: '08/09/2026',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationCenterContent(
            items: items,
            onClose: () {},
            onOpenItem: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Noticia 0'), findsOneWidget);
    expect(find.text('Noticia 3'), findsOneWidget);
    expect(find.text('Noticia 4'), findsNothing);
    expect(find.text('Ver todas (1)'), findsOneWidget);

    await tester.tap(find.text('Ver todas (1)'));
    await tester.pump();

    expect(find.text('Noticia 4'), findsOneWidget);
    expect(find.text('Ver menos'), findsOneWidget);
  });

  testWidgets('exibe as categorias funcionais separadamente', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationCenterContent(
            items: const [
              NotificationCenterItem(
                key: 'designacao:1',
                type: NotificationCenterItemType.designacao,
                title: 'Nova designação',
                subtitle: 'Promotoria',
              ),
              NotificationCenterItem(
                key: 'push:contracheque-1',
                type: NotificationCenterItemType.contracheque,
                title: 'Contracheque disponível',
                subtitle: 'Competência 09/2026',
              ),
              NotificationCenterItem(
                key: 'push:pagamento-1',
                type: NotificationCenterItemType.pagamento,
                title: 'Novo pagamento',
                subtitle: 'Pagamento disponível',
              ),
              NotificationCenterItem(
                key: 'push:afastamento-1',
                type: NotificationCenterItemType.afastamento,
                title: 'Afastamento atualizado',
                subtitle: 'Solicitação deferida',
              ),
            ],
            onClose: () {},
            onOpenItem: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Designações'), findsOneWidget);
    expect(find.text('Contracheques'), findsOneWidget);
    expect(find.text('Pagamentos'), findsOneWidget);
    expect(find.text('Afastamentos'), findsOneWidget);
  });
}
