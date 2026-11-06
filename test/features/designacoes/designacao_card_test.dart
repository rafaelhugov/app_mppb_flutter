import 'package:app_mppb_flutter/features/designacoes/models/designacao_ativa.dart';
import 'package:app_mppb_flutter/features/designacoes/ui/designacoes_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exibe categoria, titulo, periodo e ato oficial', (tester) async {
    final designacao = DesignacaoAtiva(
      id: 1002,
      tipoCodigo: 'S',
      tipoDescricao: 'Substituição Cumulativa',
      titulo: '15º Procurador de Justiça',
      dataInicial: DateTime(2026, 6, 16),
      dataFinal: DateTime(2026, 7, 30),
      ato: '456/2026',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DesignacaoCard(designacao: designacao)),
      ),
    );

    expect(find.text('Substituição Cumulativa'), findsOneWidget);
    expect(find.text('15º Procurador de Justiça'), findsOneWidget);
    expect(find.text('16/06/2026 até 30/07/2026'), findsOneWidget);
    expect(find.text('Ato 456/2026'), findsOneWidget);
  });

  testWidgets('omite ato nulo sem criar marcador vazio', (tester) async {
    final designacao = DesignacaoAtiva(
      id: 1001,
      tipoCodigo: 'T',
      tipoDescricao: 'Titularidade',
      titulo: '16º Procurador de Justiça',
      dataInicial: DateTime(2019, 1, 7),
      ato: null,
      dataPublicacao: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DesignacaoCard(designacao: designacao)),
      ),
    );

    expect(find.text('Titularidade'), findsOneWidget);
    expect(find.text('16º Procurador de Justiça'), findsOneWidget);
    expect(find.text('Desde 07/01/2019'), findsOneWidget);
    expect(find.textContaining('Ato'), findsNothing);
  });

  testWidgets('exibe titulo Teletrabalho e metadado de Natureza quando presente', (tester) async {
    final designacao = DesignacaoAtiva(
      id: 2002,
      tipoCodigo: 'F',
      tipoDescricao: 'Função',
      titulo: 'Teletrabalho',
      subtitulo: 'Departamento de Desenvolvimento de Sistemas',
      dataInicial: DateTime(2026, 6, 16),
      dataFinal: DateTime(2027, 6, 15),
      ato: '1902/2026',
      naturezaAto: 'Teletrabalho',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DesignacaoCard(designacao: designacao)),
      ),
    );

    expect(find.text('Teletrabalho'), findsNWidgets(2)); // título e metadado de natureza
    expect(find.text('Departamento de Desenvolvimento de Sistemas'), findsOneWidget);
    expect(find.text('16/06/2026 até 15/06/2027'), findsOneWidget);
    expect(find.text('Ato 1902/2026'), findsOneWidget);
    expect(find.text('Natureza'), findsOneWidget);
  });
}
