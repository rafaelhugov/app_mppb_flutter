import 'package:app_mppb_flutter/core/ui/widgets/notification_center_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra atalhos e executa a abertura de noticias', (
    tester,
  ) async {
    var openedNews = false;
    var openedDesignations = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationCenterContent(
            newsCount: 3,
            designationsCount: 1,
            onClose: () {},
            onOpenNews: () => openedNews = true,
            onOpenDesignations: () => openedDesignations = true,
          ),
        ),
      ),
    );

    expect(find.text('Notificações'), findsOneWidget);
    expect(find.text('Notícias'), findsOneWidget);
    expect(find.text('3 notícias carregadas'), findsOneWidget);
    expect(find.text('Designações'), findsOneWidget);
    expect(find.text('1 designação ativa'), findsOneWidget);

    await tester.tap(find.text('Notícias'));
    await tester.pump();

    expect(openedNews, isTrue);
    expect(openedDesignations, isFalse);
  });
}
