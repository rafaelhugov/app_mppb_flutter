import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:app_mppb_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Q5-R01 smoke minimo inicia app e exibe Home publica', (
    tester,
  ) async {
    app.main();

    final homeFinder = find.text('Bem-vindo');
    final end = DateTime.now().add(const Duration(seconds: 15));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (homeFinder.evaluate().isNotEmpty) {
        expect(homeFinder, findsOneWidget);
        return;
      }
    }

    throw TestFailure('Home publica nao ficou visivel no smoke minimo Q5-R01');
  });
}
