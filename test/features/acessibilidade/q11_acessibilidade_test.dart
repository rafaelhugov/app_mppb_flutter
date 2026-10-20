import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_mppb_flutter/core/ui/mppb_app_bar.dart';
import 'package:app_mppb_flutter/features/auth/providers/auth_provider.dart';
import 'package:app_mppb_flutter/features/auth/ui/login_page.dart';
import 'package:app_mppb_flutter/features/public/ui/public_dashboard_page.dart';
import 'package:app_mppb_flutter/features/processos/ui/consulta_processos_page.dart';
import 'package:app_mppb_flutter/features/diario_oficial/ui/diario_oficial_page.dart';
import 'package:app_mppb_flutter/features/contra_cheque/ui/contra_cheque_page.dart';
import 'package:app_mppb_flutter/features/carteira/ui/carteira_page.dart';
import 'package:app_mppb_flutter/features/carteira/models/usuario_carteira.dart';
import 'package:app_mppb_flutter/features/carteira/providers/carteira_provider.dart';
import 'package:app_mppb_flutter/features/noticias/providers/noticia_provider.dart';
import 'package:app_mppb_flutter/features/designacoes/providers/designacoes_provider.dart';
import 'package:app_mppb_flutter/features/perfil/providers/preferencias_notificacao_provider.dart';

class _MockAuthenticatedNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthState(isAuthenticated: true, token: 'mock-token');
}

class _MockErrorAuthNotifier extends AuthNotifier {
  @override
  AuthState build() =>
      AuthState(errorMessage: 'Credenciais inválidas. Tente novamente.');
}

class _MockNoticiaNotifier extends NoticiaNotifier {
  @override
  NoticiaState build() => NoticiaState();
}

class _MockDesignacoesNotifier extends DesignacoesNotifier {
  @override
  DesignacoesState build() => const DesignacoesState();
}

class _MockPreferenciasNotificacaoNotifier
    extends PreferenciasNotificacaoNotifier {
  @override
  PreferenciasNotificacaoState build() => const PreferenciasNotificacaoState();
}

class _MockCarteiraNotifier extends CarteiraNotifier {
  @override
  CarteiraState build() => CarteiraState(
    isLoading: false,
    data: UsuarioCarteira(
      nome: 'Servidor Teste',
      cargo: 'Analista Ministerial',
      matricula: '12345',
      tipoCargo: 'S',
      cpf: '000.000.000-00',
    ),
  );
}

Widget _buildTestApp(
  Widget child, {
  TextScaler textScaler = const TextScaler.linear(1.0),
  List<dynamic>? overrides,
}) {
  return ProviderScope(
    overrides: [
      noticiaProvider.overrideWith(() => _MockNoticiaNotifier()),
      designacoesProvider.overrideWith(() => _MockDesignacoesNotifier()),
      ...?overrides?.cast(),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(411, 914),
          textScaler: textScaler,
        ),
        child: Material(child: child),
      ),
    ),
  );
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('Q11-T01 — Labels Semânticos e Tooltips em Controles', () {
    testWidgets(
      'MppbAppBar pública possui tooltips acessíveis em ações e ExcludeSemantics no brasão',
      (tester) async {
        await tester.pumpWidget(
          _buildTestApp(const Scaffold(appBar: MppbAppBar())),
        );
        await tester.pump();

        // Tooltip de Notificações
        final notifFinder = find.byTooltip('Notificações');
        expect(notifFinder, findsOneWidget);

        // Botão Entrar legível
        expect(find.text('Entrar'), findsOneWidget);

        // Brasão decorativo com ExcludeSemantics
        final imageFinder = find.byType(Image);
        if (imageFinder.evaluate().isNotEmpty) {
          final excludeSemanticsFinder = find.ancestor(
            of: imageFinder.first,
            matching: find.byType(ExcludeSemantics),
          );
          expect(excludeSemanticsFinder, findsOneWidget);
        }
      },
    );

    testWidgets('MppbAppBar autenticada mantém saída apenas no Perfil', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const Scaffold(appBar: MppbAppBar()),
          overrides: [
            authProvider.overrideWith(() => _MockAuthenticatedNotifier()),
            preferenciasNotificacaoProvider.overrideWith(
              () => _MockPreferenciasNotificacaoNotifier(),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byTooltip('Sair da conta'), findsNothing);
    });

    testWidgets(
      'LoginPage possui tooltip no botão voltar e ExcludeSemantics no brasão',
      (tester) async {
        await tester.pumpWidget(_buildTestApp(const LoginPage()));
        await tester.pump();

        final backButton = find.byTooltip('Voltar');
        expect(backButton, findsOneWidget);

        // Brasão decorativo
        final imageFinder = find.byType(Image);
        if (imageFinder.evaluate().isNotEmpty) {
          final excludeSemanticsFinder = find.ancestor(
            of: imageFinder.first,
            matching: find.byType(ExcludeSemantics),
          );
          expect(excludeSemanticsFinder, findsOneWidget);
        }
      },
    );

    testWidgets(
      'CarteiraPage possui semântica para flip card e QR Code informativo',
      (tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            const CarteiraPage(),
            overrides: [
              carteiraProvider.overrideWith(() => _MockCarteiraNotifier()),
            ],
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Semântica de virar cartão
        final flipSemantics = find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label?.contains('Virar para') ?? false),
        );
        expect(flipSemantics, findsWidgets);

        // Semântica do QR Code informando propósito sem vazar dados sensíveis
        final qrSemantics = find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label?.contains(
                    'validação da carteira funcional por leitor externo',
                  ) ??
                  false),
        );
        expect(qrSemantics, findsWidgets);
      },
    );
  });

  group('Q11-T02 & Q11-T03 — Guidelines Flutter (Touch Target e Labels)', () {
    testWidgets(
      'LoginPage atende androidTapTargetGuideline e labeledTapTargetGuideline',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(_buildTestApp(const LoginPage()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Guideline de touch target mínimo (48x48dp Android, 44x44pt iOS)
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));

        // Guideline de labels semânticos em controles acionáveis
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      },
    );

    testWidgets(
      'MppbAppBar atende androidTapTargetGuideline, iOSTapTargetGuideline e labeledTapTargetGuideline',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(
          _buildTestApp(const Scaffold(appBar: MppbAppBar())),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      },
    );
  });

  group('Q11-T04 — Contraste de Texto', () {
    testWidgets(
      'LoginPage atende textContrastGuideline em seus elementos mensuráveis',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(_buildTestApp(const LoginPage()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        await expectLater(tester, meetsGuideline(textContrastGuideline));
      },
    );
  });

  group('Q11-T05 — Text Scaling (1.0, 1.3, 1.5, 2.0)', () {
    final scales = [1.0, 1.3, 1.5, 2.0];

    for (final scale in scales) {
      testWidgets(
        'PublicDashboardPage não apresenta overflow com textScaler $scale',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.625;
          addTearDown(() => tester.view.reset());

          await tester.pumpWidget(
            _buildTestApp(
              const PublicDashboardPage(),
              textScaler: TextScaler.linear(scale),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('LoginPage não apresenta overflow com textScaler $scale', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(
          _buildTestApp(
            const LoginPage(),
            textScaler: TextScaler.linear(scale),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'ConsultaProcessosPage não apresenta overflow com textScaler $scale',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.625;
          addTearDown(() => tester.view.reset());

          await tester.pumpWidget(
            _buildTestApp(
              const ConsultaProcessosPage(),
              textScaler: TextScaler.linear(scale),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'DiarioOficialPage não apresenta overflow com textScaler $scale',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.625;
          addTearDown(() => tester.view.reset());

          await tester.pumpWidget(
            _buildTestApp(
              const DiarioOficialPage(),
              textScaler: TextScaler.linear(scale),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'ContraChequePage não apresenta overflow com textScaler $scale',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.625;
          addTearDown(() => tester.view.reset());

          await tester.pumpWidget(
            _buildTestApp(
              const ContraChequePage(),
              textScaler: TextScaler.linear(scale),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('Q11-T10 & Q11-T15 — Formulário de Login e Navegação por Foco', () {
    testWidgets(
      'Campos de login possuem labels persistentes e foco sequencial correto',
      (tester) async {
        await tester.pumpWidget(_buildTestApp(const LoginPage()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(2));

        final usuarioField = textFields.first;
        final senhaField = textFields.last;
        final entrarBtn = find.widgetWithText(ElevatedButton, 'ACESSAR');

        expect(usuarioField, findsOneWidget);
        expect(senhaField, findsOneWidget);
        expect(entrarBtn, findsOneWidget);

        // Foco inicial
        await tester.tap(usuarioField);
        await tester.pump();
        expect(
          tester
              .widget<EditableText>(
                find.descendant(
                  of: usuarioField,
                  matching: find.byType(EditableText),
                ),
              )
              .focusNode
              .hasFocus,
          isTrue,
        );

        // Próximo foco para campo senha
        await tester.testTextInput.receiveAction(TextInputAction.next);
        await tester.pump();
        expect(
          tester
              .widget<EditableText>(
                find.descendant(
                  of: senhaField,
                  matching: find.byType(EditableText),
                ),
              )
              .focusNode
              .hasFocus,
          isTrue,
        );
      },
    );

    testWidgets('Botão mostrar/ocultar senha possui tooltip dinâmico', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(const LoginPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final toggleFinder = find.byTooltip('Mostrar senha');
      expect(toggleFinder, findsOneWidget);

      await tester.tap(toggleFinder);
      await tester.pump();

      final toggleHideFinder = find.byTooltip('Ocultar senha');
      expect(toggleHideFinder, findsOneWidget);
    });
  });

  group('Q11-T11 & Q11-T12 — Feedback de Erro e Loading com Semântica', () {
    testWidgets('Mensagem de erro de login possui ícone, texto e liveRegion', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          const LoginPage(),
          overrides: [
            authProvider.overrideWith(() => _MockErrorAuthNotifier()),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Container de erro visível com ícone e liveRegion
      final errorIcon = find.byIcon(Icons.error_outline_rounded);
      expect(errorIcon, findsOneWidget);

      final liveRegionSemantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.liveRegion == true,
      );
      expect(liveRegionSemantics, findsOneWidget);
      expect(
        find.text('Credenciais inválidas. Tente novamente.'),
        findsOneWidget,
      );
    });
  });

  group(
    'Q11-T16 / Q11-C30 — Orientação Landscape combinada com Text Scaling 2.0x',
    () {
      testWidgets(
        'PublicDashboardPage em landscape com TextScaler 2.0 não apresenta overflow',
        (tester) async {
          tester.view.physicalSize = const Size(2400, 1080);
          tester.view.devicePixelRatio = 2.625;
          addTearDown(() => tester.view.reset());

          await tester.pumpWidget(
            _buildTestApp(
              const PublicDashboardPage(),
              textScaler: const TextScaler.linear(2.0),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'LoginPage em landscape com TextScaler 2.0 não apresenta overflow',
        (tester) async {
          tester.view.physicalSize = const Size(2400, 1080);
          tester.view.devicePixelRatio = 2.625;
          addTearDown(() => tester.view.reset());

          await tester.pumpWidget(
            _buildTestApp(
              const LoginPage(),
              textScaler: const TextScaler.linear(2.0),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'ConsultaProcessosPage em landscape com TextScaler 2.0 não apresenta overflow',
        (tester) async {
          tester.view.physicalSize = const Size(2400, 1080);
          tester.view.devicePixelRatio = 2.625;
          addTearDown(() => tester.view.reset());

          await tester.pumpWidget(
            _buildTestApp(
              const ConsultaProcessosPage(),
              textScaler: const TextScaler.linear(2.0),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          expect(tester.takeException(), isNull);
        },
      );
    },
  );
}
