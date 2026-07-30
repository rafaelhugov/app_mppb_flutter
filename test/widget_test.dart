import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke test harness renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Concessão de Folga'))),
    );

    expect(find.text('Concessão de Folga'), findsOneWidget);
  });
}
