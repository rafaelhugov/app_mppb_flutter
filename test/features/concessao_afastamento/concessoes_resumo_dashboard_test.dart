import 'package:app_mppb_flutter/features/concessao_afastamento/models/concessao_afastamento.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/tipo_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/ui/widgets/concessoes_resumo_dashboard.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/ui/widgets/concessoes_vigentes_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('pt', 'BR')],
    home: Scaffold(body: child),
  );
}

void main() {
  group('ConcessoesResumoDashboard', () {
    testWidgets('não renderiza nada se a lista de concessões for vazia', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ConcessoesResumoDashboard(concessoes: [])),
      );

      expect(find.byType(ConcessoesResumoDashboard), findsOneWidget);
      expect(find.text('Resumo de Concessões'), findsNothing);
    });

    testWidgets(
      'inicia recolhido exibindo cabeçalho e progresso, e expande ao tocar exibindo as categorias',
      (tester) async {
        const concessoes = [
          ConcessaoAfastamento(
            id: 1,
            tipo: TipoConcessao.ferias,
            diasConcedidos: 30,
            saldoRestante: 20,
          ),
          ConcessaoAfastamento(
            id: 2,
            tipo: TipoConcessao.ferias,
            diasConcedidos: 30,
            saldoRestante: 10,
          ),
          ConcessaoAfastamento(
            id: 3,
            tipo: TipoConcessao.licencaPremio,
            diasConcedidos: 90,
            saldoRestante: 15,
          ),
        ];

        await tester.pumpWidget(
          _wrap(const ConcessoesResumoDashboard(concessoes: concessoes)),
        );

        // 1. Cabeçalho e progresso visíveis no estado recolhido inicial
        expect(find.text('Resumo de Concessões'), findsOneWidget);
        expect(find.text('3 concessões ativas no total'), findsOneWidget);
        expect(find.text('45 dias livres'), findsOneWidget);
        expect(find.textContaining('Disponível: 45 dias'), findsOneWidget);
        expect(find.textContaining('Usufruído: 105 dias'), findsOneWidget);

        // Categorias ainda NÃO visíveis pois inicia recolhido
        expect(find.text('Férias'), findsNothing);
        expect(find.text('Licença Especial'), findsNothing);

        // 2. Toca no cabeçalho para expandir
        await tester.tap(find.text('Resumo de Concessões'));
        await tester.pumpAndSettle();

        // Agora as categorias aparecem
        expect(find.text('Férias'), findsOneWidget);
        expect(find.text('30d'), findsOneWidget);
        expect(find.text('2 períodos'), findsOneWidget);

        expect(find.text('Licença Especial'), findsOneWidget);
        expect(find.text('15d'), findsOneWidget);
        expect(find.text('1 período'), findsOneWidget);

        // 3. Toca novamente para recolher
        await tester.tap(find.text('Resumo de Concessões'));
        await tester.pumpAndSettle();

        expect(find.text('Férias'), findsNothing);
        expect(find.text('Licença Especial'), findsNothing);
      },
    );

    testWidgets(
      'dispara onTipoSelecionado ao tocar na categoria após expandir',
      (tester) async {
        TipoConcessao? selecionado;

        const concessoes = [
          ConcessaoAfastamento(
            id: 1,
            tipo: TipoConcessao.ferias,
            diasConcedidos: 30,
            saldoRestante: 30,
          ),
          ConcessaoAfastamento(
            id: 2,
            tipo: TipoConcessao.plantao,
            diasConcedidos: 2,
            saldoRestante: 2,
          ),
        ];

        await tester.pumpWidget(
          _wrap(
            ConcessoesResumoDashboard(
              concessoes: concessoes,
              filtroTipoSelecionado: null,
              onTipoSelecionado: (tipo) {
                selecionado = tipo;
              },
            ),
          ),
        );

        // Expande o dashboard
        await tester.tap(find.text('Resumo de Concessões'));
        await tester.pumpAndSettle();

        // Toca em Férias
        await tester.tap(find.text('Férias'));
        await tester.pumpAndSettle();

        expect(selecionado, TipoConcessao.ferias);
      },
    );
  });

  group('ConcessoesVigentesList com Dashboard Integrado', () {
    testWidgets('exibe EmptyState quando concessoes for vazio', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ConcessoesVigentesList(
            concessoes: const [],
            isMembro: false,
            isLoading: false,
            onRetry: () {},
            onRefresh: () async {},
          ),
        ),
      );

      expect(
        find.text('Nenhuma concessão vigente encontrada.'),
        findsOneWidget,
      );
      expect(find.text('Resumo de Concessões'), findsNothing);
    });

    testWidgets(
      'exibe dashboard e filtra os cards abaixo ao expandir e selecionar tipo',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        const concessoes = [
          ConcessaoAfastamento(
            id: 1,
            tipo: TipoConcessao.ferias,
            diasConcedidos: 30,
            saldoRestante: 20,
            periodo: 1,
            anoReferencia: 2025,
          ),
          ConcessaoAfastamento(
            id: 2,
            tipo: TipoConcessao.plantao,
            diasConcedidos: 3,
            saldoRestante: 3,
          ),
        ];

        await tester.pumpWidget(
          _wrap(
            ConcessoesVigentesList(
              concessoes: concessoes,
              isMembro: false,
              isLoading: false,
              onRetry: () {},
              onRefresh: () async {},
            ),
          ),
        );

        // O dashboard está presente com 2 concessões (recolhido)
        expect(find.text('Resumo de Concessões'), findsOneWidget);
        expect(find.text('2 concessões ativas no total'), findsOneWidget);

        // Expande o dashboard
        await tester.tap(find.text('Resumo de Concessões'));
        await tester.pumpAndSettle();

        // Toca no card de Férias do dashboard para filtrar
        await tester.tap(find.text('Férias').first);
        await tester.pumpAndSettle();

        // Banner de filtro ativo aparece
        expect(find.text('Filtrando por: Férias'), findsOneWidget);

        // Toca em "Ver todas" para remover o filtro
        await tester.tap(find.text('Ver todas'));
        await tester.pumpAndSettle();

        expect(find.text('Filtrando por: Férias'), findsNothing);
      },
    );
  });
}
