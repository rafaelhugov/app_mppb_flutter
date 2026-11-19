import 'package:app_mppb_flutter/features/auth/providers/auth_provider.dart';
import 'package:app_mppb_flutter/features/mensagens/data/mensagens_repository.dart';
import 'package:app_mppb_flutter/features/mensagens/models/mensagem_anexo_model.dart';
import 'package:app_mppb_flutter/features/mensagens/models/mensagem_aviso_model.dart';
import 'package:app_mppb_flutter/features/mensagens/providers/permissao_mensagens_provider.dart';
import 'package:app_mppb_flutter/features/mensagens/ui/pages/caixa_mensagens_page.dart';
import 'package:app_mppb_flutter/features/mensagens/ui/widgets/mensagem_bolha_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthState(isAuthenticated: true, token: 'tok-123');
}

class _FakeMensagensRepository extends MensagensRepository {
  _FakeMensagensRepository() : super(Dio());

  List<int> entreguesConfirmadas = [];
  int? cienciaConfirmadaId;

  @override
  Future<CaixaEntradaPageModel> listarRecebidas({
    String filtro = 'TODAS',
    int pagina = 0,
    int tamanho = 20,
  }) async {
    return CaixaEntradaPageModel(
      itens: [
        MensagemAvisoModel(
          id: 10,
          titulo: 'Comunicado PGJ',
          conteudo: 'Reunião institucional amanhã às 9h.',
          prioridade: PrioridadeMensagem.urgente,
          modalidade: ModalidadeEnvio.broadcast,
          exigeCiencia: true,
          remetenteNome: 'Procuradoria-Geral de Justiça',
          dataEnvio: DateTime(2026, 11, 19, 9, 0),
          status: StatusDestinatario.pendente,
          anexos: const [
            MensagemAnexoModel(
              id: 1,
              categoria: CategoriaAnexo.documento,
              nomeOriginal: 'pauta.pdf',
              mimeType: 'application/pdf',
              tamanhoBytes: 20480,
            ),
          ],
        ),
      ],
      pagina: 0,
      tamanho: 20,
      totalElementos: 1,
      totalPaginas: 1,
      totalNaoLidas: 1,
    );
  }

  @override
  Future<void> confirmarEntregaEmLote(List<int> mensagemIds) async {
    entreguesConfirmadas = mensagemIds;
  }

  @override
  Future<MensagemAvisoModel> confirmarCiencia(int id) async {
    cienciaConfirmadaId = id;
    return MensagemAvisoModel(
      id: id,
      titulo: 'Comunicado PGJ',
      conteudo: 'Reunião institucional amanhã às 9h.',
      prioridade: PrioridadeMensagem.urgente,
      modalidade: ModalidadeEnvio.broadcast,
      exigeCiencia: true,
      remetenteNome: 'Procuradoria-Geral de Justiça',
      dataEnvio: DateTime(2026, 11, 19, 9, 0),
      status: StatusDestinatario.lido,
      dataEntrega: DateTime(2026, 11, 19, 9, 1),
      dataLeitura: DateTime(2026, 11, 19, 9, 2),
      dataCiencia: DateTime(2026, 11, 19, 9, 2),
    );
  }
}

void main() {
  testWidgets(
    'CaixaMensagensPage renderiza bolha unilateral, confirma entrega automática e ciência explícita',
    (tester) async {
      final fakeRepo = _FakeMensagensRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(_FakeAuthNotifier.new),
            mensagensRepositoryProvider.overrideWithValue(fakeRepo),
            podeEnviarMensagensProvider.overrideWith((ref) async => false),
          ],
          child: const MaterialApp(home: CaixaMensagensPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Comunicado PGJ'), findsOneWidget);
      expect(find.text('URGENTE'), findsOneWidget);
      expect(find.text('pauta.pdf'), findsOneWidget);
      expect(find.text('Confirmar Ciência'), findsOneWidget);
      expect(find.text('Painel de Envio de Avisos'), findsNothing);
      expect(fakeRepo.entreguesConfirmadas, [10]);

      await tester.tap(find.text('Confirmar Ciência'));
      await tester.pumpAndSettle();

      expect(fakeRepo.cienciaConfirmadaId, 10);
      expect(find.textContaining('Ciência confirmada em'), findsOneWidget);
    },
  );

  testWidgets(
    'CaixaMensagensPage exibe card explicativo do Painel de Envio de Avisos quando usuario tem permissao admin',
    (tester) async {
      final fakeRepo = _FakeMensagensRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(_FakeAuthNotifier.new),
            mensagensRepositoryProvider.overrideWithValue(fakeRepo),
            podeEnviarMensagensProvider.overrideWith((ref) async => true),
          ],
          child: const MaterialApp(home: CaixaMensagensPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Painel de Envio de Avisos'), findsOneWidget);
      expect(
        find.text('Enviar comunicados, gerenciar grupos e acompanhar leituras'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'MensagemBolhaCard suporta aviso somente de mídia sem título e sem texto',
    (tester) async {
      const avisoSoDocumento = MensagemAvisoModel(
        id: 22,
        prioridade: PrioridadeMensagem.normal,
        modalidade: ModalidadeEnvio.unicast,
        exigeCiencia: false,
        status: StatusDestinatario.entregue,
        anexos: [
          MensagemAnexoModel(
            id: 2,
            categoria: CategoriaAnexo.documento,
            nomeOriginal: 'relatorio.md',
            mimeType: 'text/markdown',
            tamanhoBytes: 4096,
          ),
        ],
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MensagemBolhaCard(mensagem: avisoSoDocumento)),
          ),
        ),
      );

      expect(find.text('relatorio.md'), findsOneWidget);
      expect(find.text('MD • 4.0 KB'), findsOneWidget);
    },
  );
}
