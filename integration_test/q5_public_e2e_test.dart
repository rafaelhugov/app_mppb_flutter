import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:app_mppb_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Q5-E2E-PUB-01 jornadas publicas seguras em Android', (
    tester,
  ) async {
    app.main();

    await _waitForText(tester, 'Bem-vindo');
    expect(find.text('Serviços ao Cidadão'), findsOneWidget);
    expect(find.text('Certidão'), findsOneWidget);
    expect(find.text('Diário Oficial'), findsOneWidget);
    expect(find.text('Notícias'), findsWidgets);
    expect(find.text('Ouvidoria'), findsWidgets);
    expect(find.text('Processos'), findsOneWidget);
    expect(find.text('Contatos'), findsOneWidget);

    await _tapFinder(
      tester,
      find.byKey(const ValueKey('q5-public-service-contatos')),
    );
    await _waitForText(tester, 'Contatos e Atendimento');
    expect(find.text('Ouvidoria'), findsWidgets);
    expect(find.text('E-mail'), findsWidgets);

    await _androidBack(tester);
    await _waitForText(tester, 'Bem-vindo');
    await _tapText(tester, 'Todas as notícias');

    await _waitForAny(tester, [
      find.text('Tentar novamente'),
      find.textContaining('min de leitura'),
      find.text('Nenhuma notícia encontrada no momento.'),
      find.textContaining('Não foi possível'),
    ], timeout: const Duration(seconds: 25));

    final encontrouLista = find
        .textContaining('min de leitura')
        .evaluate()
        .isNotEmpty;
    final encontrouErro =
        find.text('Tentar novamente').evaluate().isNotEmpty ||
        find
            .text('Nenhuma notícia encontrada no momento.')
            .evaluate()
            .isNotEmpty ||
        find.textContaining('Não foi possível').evaluate().isNotEmpty;

    expect(encontrouLista || encontrouErro, isTrue);

    if (encontrouLista) {
      final item = find.textContaining('min de leitura').first;
      await tester.ensureVisible(item);
      await tester.tap(item);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await _waitForAny(tester, [
        find.text('Abrir notícia'),
        find.text('Compartilhar'),
        find.byType(BottomSheet),
      ]);
      await _androidBack(tester);
    }

    await _androidBack(tester);
    await _waitForText(tester, 'Bem-vindo');
  });
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await _tapFinder(tester, find.text(text).first);
}

Future<void> _tapFinder(WidgetTester tester, Finder finder) async {
  await _waitForFinder(tester, finder);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

Future<void> _androidBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

Future<void> _waitForText(
  WidgetTester tester,
  String text, {
  Duration timeout = const Duration(seconds: 15),
}) {
  return _waitForFinder(tester, find.text(text), timeout: timeout);
}

Future<void> _waitForFinder(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure('Elemento nao encontrado dentro de $timeout: $finder');
}

Future<void> _waitForAny(
  WidgetTester tester,
  List<Finder> finders, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finders.any((finder) => finder.evaluate().isNotEmpty)) {
      return;
    }
  }
  throw TestFailure('Nenhuma condicao observavel encontrada em $timeout');
}
