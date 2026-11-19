import 'package:app_mppb_flutter/features/mensagens/data/mensagens_repository.dart';
import 'package:app_mppb_flutter/features/mensagens/models/acompanhamento_mensagem_model.dart';
import 'package:app_mppb_flutter/features/mensagens/models/grupo_mensagem_model.dart';
import 'package:app_mppb_flutter/features/mensagens/models/mensagem_anexo_model.dart';
import 'package:app_mppb_flutter/features/mensagens/models/mensagem_aviso_model.dart';
import 'package:app_mppb_flutter/features/mensagens/providers/envio_mensagem_provider.dart';
import 'package:app_mppb_flutter/features/mensagens/providers/permissao_mensagens_provider.dart';
import 'package:app_mppb_flutter/features/mensagens/ui/pages/compor_mensagem_page.dart';
import 'package:app_mppb_flutter/features/mensagens/ui/pages/painel_remetente_page.dart';
import 'package:app_mppb_flutter/features/mensagens/ui/widgets/rich_markdown_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRemetenteRepo extends MensagensRepository {
  _FakeRemetenteRepo() : super(Dio());

  @override
  Future<List<MensagemEnviadaModel>> listarEnviadas({
    bool arquivada = false,
    int pagina = 0,
    int tamanho = 20,
  }) async {
    return const [
      MensagemEnviadaModel(
        id: 77,
        titulo: 'Aviso Geral da PGJ',
        conteudo: 'Expediente normal.',
        prioridade: PrioridadeMensagem.importante,
        modalidade: ModalidadeEnvio.broadcast,
        exigeCiencia: true,
        statusPublicacao: 'ENVIADA',
        totalDestinatarios: 500,
        totalEntregues: 420,
        totalLidos: 310,
        totalCientes: 295,
        totalPendentes: 80,
      ),
    ];
  }

  @override
  Future<CatalogoGruposRhModel> catalogoGruposRh() async {
    return const CatalogoGruposRhModel();
  }

  @override
  Future<List<GrupoPersonalizadoModel>> listarGruposPersonalizados() async {
    return const [];
  }

  @override
  Future<int> previaAlcance({
    required ModalidadeEnvio modalidade,
    Map<String, dynamic>? criterios,
  }) async {
    return 500;
  }

  @override
  Future<MensagemEnviadaModel> enviarOuAgendar({
    String? titulo,
    String? conteudo,
    required PrioridadeMensagem prioridade,
    required ModalidadeEnvio modalidade,
    required bool exigeCiencia,
    Map<String, dynamic>? criterios,
    List<int> anexoIds = const [],
    DateTime? dataAgendamento,
    DateTime? dataExpiracao,
  }) async {
    return MensagemEnviadaModel(
      id: 88,
      titulo: titulo,
      conteudo: conteudo,
      prioridade: prioridade,
      modalidade: modalidade,
      exigeCiencia: exigeCiencia,
      statusPublicacao: 'ENVIADA',
      totalDestinatarios: 500,
      totalEntregues: 0,
      totalLidos: 0,
      totalCientes: 0,
      totalPendentes: 500,
    );
  }
}

void main() {
  testWidgets(
    'PainelRemetentePage bloqueia acesso quando usuario nao possui permissao admin',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mensagensRepositoryProvider.overrideWithValue(_FakeRemetenteRepo()),
            podeEnviarMensagensProvider.overrideWith((ref) async => false),
          ],
          child: const MaterialApp(home: PainelRemetentePage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Acesso restrito ao PGJ e autoridades designadas.'),
        findsOneWidget,
      );
      expect(find.text('Novo Aviso'), findsNothing);
    },
  );

  testWidgets(
    'PainelRemetentePage exibe avisos enviados e metricas quando autorizado',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mensagensRepositoryProvider.overrideWithValue(_FakeRemetenteRepo()),
            podeEnviarMensagensProvider.overrideWith((ref) async => true),
          ],
          child: const MaterialApp(home: PainelRemetentePage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Aviso Geral da PGJ'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      expect(find.text('420'), findsOneWidget);
      expect(find.text('310'), findsOneWidget);
      expect(find.text('295'), findsOneWidget);
      expect(find.text('Novo Aviso'), findsOneWidget);
    },
  );

  test(
    'EnvioMensagemNotifier rejeita aviso totalmente vazio e permite aviso somente com anexo/audio',
    () async {
      final container = ProviderContainer(
        overrides: [
          mensagensRepositoryProvider.overrideWithValue(_FakeRemetenteRepo()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(envioMensagemProvider.notifier);

      final falha = await notifier.enviar();
      expect(falha, isNull);
      expect(
        container.read(envioMensagemProvider).errorMessage,
        contains('Informe um texto ou adicione ao menos uma mídia'),
      );

      notifier.adicionarAnexoPreCarregado(
        const MensagemAnexoModel(
          id: 9,
          categoria: CategoriaAnexo.audio,
          nomeOriginal: 'voz.m4a',
          mimeType: 'audio/mp4',
          tamanhoBytes: 8192,
          duracaoSegundos: 12,
        ),
      );

      final sucesso = await notifier.enviar();
      expect(sucesso, isNotNull);
      expect(sucesso!.id, 88);
    },
  );

  testWidgets(
    'ComporMensagemPage exibe barra de formatação, bandeja de 4 mídias estilo mensageiro e configurações',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mensagensRepositoryProvider.overrideWithValue(_FakeRemetenteRepo()),
            podeEnviarMensagensProvider.overrideWith((ref) async => true),
          ],
          child: const MaterialApp(home: ComporMensagemPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byTooltip('Negrito'), findsOneWidget);
      expect(find.byTooltip('Itálico'), findsOneWidget);
      expect(find.byTooltip('Tachado'), findsOneWidget);
      expect(find.text('Áudio'), findsOneWidget);
      expect(find.text('Foto'), findsOneWidget);
      expect(find.text('Vídeo'), findsOneWidget);
      expect(find.text('Arquivo'), findsOneWidget);
      expect(find.text('Confirmar ciência'), findsOneWidget);
      expect(find.text('Agendar envio'), findsOneWidget);
      expect(find.text('Expiração do aviso'), findsOneWidget);
    },
  );

  test(
    'EnvioMensagemNotifier exige margem mínima de 1 hora entre envio/agendamento e expiração',
    () {
      final container = ProviderContainer(
        overrides: [
          mensagensRepositoryProvider.overrideWithValue(_FakeRemetenteRepo()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(envioMensagemProvider.notifier);
      final agendamento = DateTime.now().add(const Duration(days: 1));
      notifier.setDataAgendamento(agendamento);

      final aceitouMenor = notifier.setDataExpiracao(
        agendamento.add(const Duration(minutes: 30)),
      );
      expect(aceitouMenor, isFalse);
      expect(
        container.read(envioMensagemProvider).errorMessage,
        contains('1 hora'),
      );

      final aceitouValido = notifier.setDataExpiracao(
        agendamento.add(const Duration(hours: 2)),
      );
      expect(aceitouValido, isTrue);
      expect(container.read(envioMensagemProvider).dataExpiracao, isNotNull);
    },
  );

  testWidgets(
    'RichMarkdownEditingController aplica formatacao visual imediata mantendo o mesmo tamanho do texto',
    (tester) async {
      final controller = RichMarkdownEditingController(
        text: 'Olá **negrito**, *itálico* e ~~tachado~~',
      );
      addTearDown(controller.dispose);

      late TextSpan spanGerado;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              spanGerado = controller.buildTextSpan(
                context: context,
                style: const TextStyle(fontSize: 14),
                withComposing: false,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(spanGerado.toPlainText(), controller.text);

      controller.selection = const TextSelection(baseOffset: 0, extentOffset: 3);
      controller.alternarEnvoltorio('**');
      expect(controller.text.startsWith('**Olá**'), isTrue);
      controller.alternarEnvoltorio('**');
      expect(controller.text.startsWith('Olá'), isTrue);
    },
  );
}

