import 'package:app_mppb_flutter/features/mensagens/models/mensagem_aviso_model.dart';
import 'package:app_mppb_flutter/features/mensagens/providers/caixa_entrada_provider.dart';
import 'package:app_mppb_flutter/features/mensagens/ui/widgets/aviso_urgente_global_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

MensagemAvisoModel _msg({
  required int id,
  required PrioridadeMensagem prioridade,
  required StatusDestinatario status,
  String? titulo,
  String? corpo,
}) {
  return MensagemAvisoModel(
    id: id,
    titulo: titulo,
    conteudo: corpo,
    prioridade: prioridade,
    modalidade: ModalidadeEnvio.broadcast,
    exigeCiencia: false,
    remetenteNome: 'PGJ',
    dataEnvio: DateTime(2026, 11, 24, 10),
    status: status,
    anexos: const [],
  );
}

void main() {
  test('CaixaEntradaState.urgentesNaoLidas filtra urgentes nao lidas', () {
    final state = CaixaEntradaState(
      itens: [
        _msg(
          id: 1,
          prioridade: PrioridadeMensagem.urgente,
          status: StatusDestinatario.entregue,
          titulo: 'Alerta 1',
        ),
        _msg(
          id: 2,
          prioridade: PrioridadeMensagem.urgente,
          status: StatusDestinatario.lido,
          titulo: 'Alerta Lido',
        ),
        _msg(
          id: 3,
          prioridade: PrioridadeMensagem.normal,
          status: StatusDestinatario.pendente,
          titulo: 'Normal',
        ),
      ],
    );

    expect(state.totalUrgentesNaoLidas, 1);
    expect(state.urgentesNaoLidas.single.id, 1);
  });

  testWidgets('AvisoUrgenteGlobalBanner exibe 1 ou varios avisos e aciona onTap', (
    tester,
  ) async {
    var tapped = false;
    final single = [
      _msg(
        id: 10,
        prioridade: PrioridadeMensagem.urgente,
        status: StatusDestinatario.entregue,
        titulo: 'Manutenção crítica',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AvisoUrgenteGlobalBanner(
            urgentes: single,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('URGENTE: Manutenção crítica'), findsOneWidget);
    await tester.tap(find.text('Ler'));
    expect(tapped, isTrue);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AvisoUrgenteGlobalBanner(
            urgentes: [
              ...single,
              _msg(
                id: 11,
                prioridade: PrioridadeMensagem.urgente,
                status: StatusDestinatario.pendente,
                titulo: 'Segundo alerta',
              ),
            ],
            onTap: () {},
          ),
        ),
      ),
    );

    expect(
      find.text('Você tem 2 avisos urgentes pendentes de leitura'),
      findsOneWidget,
    );
  });

  testWidgets('mostrarModalAvisoUrgente permite adiar ou ler agora', (
    tester,
  ) async {
    bool? resultado;
    final urgentes = [
      _msg(
        id: 20,
        prioridade: PrioridadeMensagem.urgente,
        status: StatusDestinatario.entregue,
        titulo: 'Comunicado Urgente',
        corpo: 'Leia imediatamente.',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  resultado = await mostrarModalAvisoUrgente(
                    context,
                    urgentes: urgentes,
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Comunicado Urgente'), findsOneWidget);
    expect(find.text('Depois'), findsOneWidget);
    expect(find.text('Ler agora'), findsOneWidget);

    await tester.tap(find.text('Depois'));
    await tester.pumpAndSettle();
    expect(resultado, isFalse);

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ler agora'));
    await tester.pumpAndSettle();
    expect(resultado, isTrue);
  });
}
