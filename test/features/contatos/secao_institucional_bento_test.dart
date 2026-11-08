import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_mppb_flutter/features/contatos/ui/widgets/secao_institucional.dart';

void main() {
  group('SecaoInstitucional Bento Cards', () {
    testWidgets('Deve exibir os 3 cards dedicados e seus canais correspondentes',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SecaoInstitucional(compacta: true),
            ),
          ),
        ),
      );
      await tester.pump();

      // CARD 1: Ouvidoria
      expect(find.text('Ouvidoria do MPPB'), findsOneWidget);
      expect(
        find.text('Atendimento direto ao cidadão e servidor'),
        findsOneWidget,
      );
      expect(find.text('WhatsApp da Ouvidoria'), findsOneWidget);
      expect(find.text('(83) 99181-7355'), findsOneWidget);
      expect(find.text('Telefone Direto'), findsOneWidget);
      expect(find.text('(83) 2107-6150'), findsOneWidget);
      expect(find.text('E-mail Oficial'), findsOneWidget);
      expect(find.text('ouvidoria@mppb.mp.br'), findsOneWidget);

      // CARD 2: Sede
      expect(find.text('Edifício-Sede da PGJ'), findsOneWidget);
      expect(find.text('Procuradoria-Geral de Justiça'), findsOneWidget);
      expect(find.text('Como chegar / Abrir no mapa'), findsOneWidget);

      // CARD 3: Redes Sociais
      expect(find.text('Redes Sociais Oficiais'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('Facebook'), findsOneWidget);
      expect(find.text('X'), findsOneWidget);

      // Ícones FontAwesome esperados
      expect(find.byType(FaIcon), findsNWidgets(4));
    });
  });
}
