import 'package:app_mppb_flutter/features/contra_cheque/models/contra_cheque.dart';
import 'package:app_mppb_flutter/features/contra_cheque/ui/widgets/contracheque_lancamentos.dart';
import 'package:app_mppb_flutter/features/contra_cheque/ui/widgets/grafico_contracheque.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app(Widget child) {
    return ProviderScope(
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('resume o bruto com percentuais brasileiros', (tester) async {
    await tester.pumpWidget(
      app(
        const GraficoContracheque(
          totalVantagens: 29134.54,
          totalDescontos: 12189.97,
          salarioLiquido: 0,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 31));

    expect(find.text('BRUTO'), findsOneWidget);
    expect(find.text('R\$ 29.134,54'), findsOneWidget);
    expect(find.text('R\$ 12.189,97'), findsOneWidget);
    expect(find.text('R\$ 16.944,57'), findsOneWidget);
    expect(find.text('41,8% do bruto'), findsOneWidget);
    expect(find.text('58,2% do bruto'), findsOneWidget);
    expect(find.text('VANTAGENS'), findsNothing);
  });

  testWidgets('mantem secoes e codigos e padroniza os lancamentos', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        SingleChildScrollView(
          child: ContrachequeLancamentos(
            totalVantagens: 29134.54,
            vantagens: [
              LancamentoContracheque(
                codigo: '20',
                descricao: '  AUXILIO   ALIMENTACAO ',
                valor: 14337.50,
                tipo: 'V',
              ),
            ],
            descontos: [
              LancamentoContracheque(
                codigo: '90',
                descricao: 'IMPOSTO DE RENDA',
                valor: 12189.97,
                tipo: 'D',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Vantagens'), findsOneWidget);
    expect(find.text('Descontos'), findsOneWidget);
    expect(find.text('Auxílio-alimentação'), findsOneWidget);
    expect(find.text('Imposto de renda'), findsOneWidget);
    expect(find.text('Código 20'), findsOneWidget);
    expect(find.text('Código 90'), findsOneWidget);
    expect(find.text('49,2% do bruto'), findsOneWidget);
    expect(find.text('41,8% do bruto'), findsOneWidget);
  });
}
