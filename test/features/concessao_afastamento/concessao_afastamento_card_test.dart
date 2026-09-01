import 'package:app_mppb_flutter/features/concessao_afastamento/models/concessao_afastamento.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/solicitacao_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/status_solicitacao_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/sugestao_data_final.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/tipo_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/tipo_solicitacao_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/ui/widgets/concessao_afastamento_card.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/ui/widgets/concessao_afastamento_details_sheet.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/operacao_solicitacao_concessao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('ConcessaoAfastamentoCard', () {
    testWidgets(
      'exibe Marcar gozo quando diasConcedidos 30 e saldoRestante 30',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            _card(
              const ConcessaoAfastamento(
                id: 1,
                tipo: TipoConcessao.ferias,
                diasConcedidos: 30,
                saldoRestante: 30,
              ),
            ),
          ),
        );

        expect(find.text('Férias'), findsOneWidget);
        expect(find.text('Marcar gozo'), findsOneWidget);
      },
    );

    testWidgets(
      'exibe Marcar gozo quando diasConcedidos 30 e saldoRestante 5',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            _card(
              const ConcessaoAfastamento(
                id: 2,
                tipo: TipoConcessao.ferias,
                diasConcedidos: 30,
                saldoRestante: 5,
              ),
            ),
          ),
        );

        expect(find.text('Férias'), findsOneWidget);
        expect(find.text('Marcar gozo'), findsOneWidget);
      },
    );

    testWidgets(
      'mantem card visivel e oculta Marcar gozo com saldo zero e solicitacao futura',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            _card(
              ConcessaoAfastamento(
                id: 3,
                tipo: TipoConcessao.ferias,
                diasConcedidos: 30,
                saldoRestante: 0,
                solicitacoes: [
                  SolicitacaoConcessao(
                    id: 10,
                    tipo: TipoSolicitacaoConcessao.gozo,
                    inicio: DateTime(2027, 1, 11),
                    fim: DateTime(2027, 2, 9),
                    status: StatusSolicitacaoConcessao.deferido,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Férias'), findsOneWidget);
        expect(find.text('Saldo disponível'), findsOneWidget);
        expect(find.text('0 dias'), findsWidgets);
        expect(find.text('Período: 11/01/2027 a 09/02/2027'), findsOneWidget);
        expect(find.text('Marcar gozo'), findsNothing);
      },
    );

    testWidgets(
      'nunca habilita nova solicitacao somente por diasConcedidos quando saldo e zero',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            _card(
              const ConcessaoAfastamento(
                id: 4,
                tipo: TipoConcessao.licencaPremio,
                diasConcedidos: 90,
                saldoRestante: 0,
              ),
            ),
          ),
        );

        expect(find.text('Licença Especial'), findsOneWidget);
        expect(find.text('Marcar gozo'), findsNothing);
      },
    );

    testWidgets(
      'descarta sugestao anterior ao mudar dataInicial e envia numeroDias da sugestao escolhida',
      (tester) async {
        final dateFormat = DateFormat('dd/MM/yyyy');
        final primeiraData = DateTime.now().add(const Duration(days: 1));
        final segundaData = primeiraData.add(const Duration(days: 1));
        final primeiraFinal = primeiraData.add(const Duration(days: 9));
        final segundaFinal = segundaData.add(const Duration(days: 14));
        int? numeroDiasEnviado;

        await tester.pumpWidget(
          _wrap(
            ConcessaoAfastamentoCard(
              concessao: const ConcessaoAfastamento(
                id: 5,
                tipo: TipoConcessao.ferias,
                diasConcedidos: 30,
                saldoRestante: 30,
              ),
              onBuscarSugestoes: (_, dataInicial) async {
                final isPrimeiraData =
                    dataInicial.year == primeiraData.year &&
                    dataInicial.month == primeiraData.month &&
                    dataInicial.day == primeiraData.day;
                final numeroDias = isPrimeiraData ? 10 : 15;
                return [
                  SugestaoDataFinal(
                    numeroDias: numeroDias,
                    dataInicial: dataInicial,
                    dataFinal: dataInicial.add(Duration(days: numeroDias - 1)),
                  ),
                ];
              },
              onSolicitar: (concessao, dataInicial, numeroDias) async {
                numeroDiasEnviado = numeroDias;
              },
            ),
          ),
        );

        await tester.tap(find.text('Marcar gozo'));
        await tester.pumpAndSettle();

        await _selecionarDataInicial(tester, primeiraData);
        expect(find.text(dateFormat.format(primeiraFinal)), findsOneWidget);

        await _selecionarDataInicial(tester, segundaData);
        expect(find.text(dateFormat.format(primeiraFinal)), findsNothing);
        expect(find.text(dateFormat.format(segundaFinal)), findsOneWidget);

        await tester.tap(find.text(dateFormat.format(segundaFinal)));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Solicitar marcação'));
        await tester.pumpAndSettle();

        expect(numeroDiasEnviado, 15);
      },
    );

    testWidgets('unifica adiar e antecipar em alterar data', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ConcessaoAfastamentoDetailsSheet(
            concessao: ConcessaoAfastamento(
              id: 6,
              tipo: TipoConcessao.ferias,
              diasConcedidos: 30,
              saldoRestante: 0,
              solicitacoes: [
                SolicitacaoConcessao(
                  id: 20,
                  tipo: TipoSolicitacaoConcessao.gozo,
                  inicio: DateTime(2026, 11, 2),
                  fim: DateTime(2026, 12, 1),
                  status: StatusSolicitacaoConcessao.deferido,
                ),
              ],
            ),
            onBuscarOperacoes: (_) async => [
              OperacaoSolicitacaoConcessao.adiar,
              OperacaoSolicitacaoConcessao.antecipar,
            ],
            onExecutarOperacao:
                (_, __, {DateTime? data, DateTime? dataFim}) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alterar data'), findsOneWidget);
      expect(find.text('Adiar'), findsNothing);
      expect(find.text('Antecipar'), findsNothing);
    });

    testWidgets('desabilita confirmacao para data inicial em final de semana', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ConcessaoAfastamentoDetailsSheet(
            concessao: ConcessaoAfastamento(
              id: 7,
              tipo: TipoConcessao.ferias,
              diasConcedidos: 30,
              saldoRestante: 0,
              solicitacoes: [
                SolicitacaoConcessao(
                  id: 21,
                  tipo: TipoSolicitacaoConcessao.gozo,
                  inicio: DateTime(2026, 11, 1),
                  fim: DateTime(2026, 11, 30),
                  status: StatusSolicitacaoConcessao.deferido,
                ),
              ],
            ),
            onBuscarOperacoes: (_) async => [
              OperacaoSolicitacaoConcessao.adiar,
              OperacaoSolicitacaoConcessao.antecipar,
            ],
            onExecutarOperacao:
                (_, __, {DateTime? data, DateTime? dataFim}) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alterar data'));
      await tester.pumpAndSettle();

      expect(find.text('Selecionar data'), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirmar'),
      );
      expect(button.onPressed, isNull);
    });
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('pt', 'BR')],
    home: Scaffold(
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

Widget _card(ConcessaoAfastamento concessao) {
  return ConcessaoAfastamentoCard(
    concessao: concessao,
    onSolicitar: (concessao, dataInicial, numeroDias) async {},
  );
}

Future<void> _selecionarDataInicial(WidgetTester tester, DateTime data) async {
  await tester.tap(find.text('Data inicial'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('${data.day}').last);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}
