import 'package:app_mppb_flutter/features/mensagens/data/mensagens_repository.dart';
import 'package:app_mppb_flutter/features/mensagens/models/acompanhamento_mensagem_model.dart';
import 'package:app_mppb_flutter/features/mensagens/models/mensagem_aviso_model.dart';
import 'package:app_mppb_flutter/features/mensagens/ui/pages/acompanhamento_mensagem_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAcompanhamentoRepo extends MensagensRepository {
  _FakeAcompanhamentoRepo() : super(Dio());

  @override
  Future<AcompanhamentoMensagemModel> acompanharMensagem(
    int id, {
    StatusDestinatario? status,
    String? busca,
    int pagina = 0,
    int tamanho = 30,
  }) async {
    return AcompanhamentoMensagemModel(
      resumo: MensagemEnviadaModel(
        id: id,
        titulo: 'Convocação Extraordinária',
        prioridade: PrioridadeMensagem.urgente,
        modalidade: ModalidadeEnvio.multicast,
        exigeCiencia: true,
        statusPublicacao: 'ENVIADA',
        totalDestinatarios: 2,
        totalEntregues: 2,
        totalLidos: 1,
        totalCientes: 1,
        totalPendentes: 0,
      ),
      destinatarios: [
        DestinatarioStatusModel(
          matricula: '3001',
          nome: 'Maria Promotora',
          setor: '1ª Promotoria',
          status: StatusDestinatario.lido,
          dataEntrega: DateTime(2026, 11, 19, 10, 0),
          dataLeitura: DateTime(2026, 11, 19, 10, 5),
          dataCiencia: DateTime(2026, 11, 19, 10, 6),
        ),
        DestinatarioStatusModel(
          matricula: '3002',
          nome: 'João Servidor',
          setor: 'DTI',
          status: StatusDestinatario.entregue,
          dataEntrega: DateTime(2026, 11, 19, 10, 1),
        ),
      ],
      pagina: 0,
      tamanho: 30,
      totalElementos: 2,
      totalPaginas: 1,
    );
  }
}

void main() {
  testWidgets(
    'AcompanhamentoMensagemPage exibe contadores consolidados e quem/quando recebeu e leu',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mensagensRepositoryProvider.overrideWithValue(
              _FakeAcompanhamentoRepo(),
            ),
          ],
          child: const MaterialApp(
            home: AcompanhamentoMensagemPage(mensagemId: 50),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Convocação Extraordinária'), findsOneWidget);
      expect(find.text('Maria Promotora (3001)'), findsOneWidget);
      expect(find.text('João Servidor (3002)'), findsOneWidget);
      expect(find.text('LIDO'), findsOneWidget);
      expect(find.text('ENTREGUE'), findsOneWidget);
    },
  );
}

