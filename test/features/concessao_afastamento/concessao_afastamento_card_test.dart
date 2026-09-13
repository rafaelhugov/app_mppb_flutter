import 'package:app_mppb_flutter/features/concessao_afastamento/models/concessao_afastamento.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/solicitacao_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/status_solicitacao_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/sugestao_data_final.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/tipo_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/tipo_solicitacao_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/ui/widgets/concessao_afastamento_card.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/ui/widgets/concessao_afastamento_details_sheet.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/operacao_solicitacao_concessao.dart';
import 'package:dio/dio.dart';
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
              isMembro: false,
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

    testWidgets(
      'afastamento eleitoral informa numero de dias sem buscar intervalos',
      (tester) async {
        final dataInicial = DateTime.now().add(const Duration(days: 1));
        int? numeroDiasEnviado;

        await tester.pumpWidget(
          _wrap(
            ConcessaoAfastamentoCard(
              concessao: const ConcessaoAfastamento(
                id: 8,
                tipo: TipoConcessao.licencaEleitoral,
                diasConcedidos: 5,
                saldoRestante: 5,
                periodo: 3,
                anoReferencia: 2024,
              ),
              isMembro: false,
              onBuscarSugestoes: (concessao, dataInicial) async {
                fail('Afastamento eleitoral nao deve buscar intervalos.');
              },
              onSolicitar: (concessao, dataInicial, numeroDias) async {
                numeroDiasEnviado = numeroDias;
              },
            ),
          ),
        );

        await tester.tap(find.text('Marcar gozo'));
        await tester.pumpAndSettle();

        expect(find.text('Número de dias'), findsOneWidget);
        expect(find.text('Datas finais permitidas'), findsNothing);

        await _selecionarDataInicial(tester, dataInicial);
        await tester.enterText(find.byType(TextField), '3');
        await tester.pumpAndSettle();

        expect(find.text('Data final'), findsNothing);
        await tester.tap(find.text('Solicitar marcação'));
        await tester.pumpAndSettle();

        expect(numeroDiasEnviado, 3);
      },
    );

    testWidgets('afastamento eleitoral bloqueia periodo com final de semana', (
      tester,
    ) async {
      final sexta = _proximaDataComDiaSemana(DateTime.friday);
      int? numeroDiasEnviado;

      await tester.pumpWidget(
        _wrap(
          ConcessaoAfastamentoCard(
            concessao: const ConcessaoAfastamento(
              id: 9,
              tipo: TipoConcessao.licencaEleitoral,
              diasConcedidos: 5,
              saldoRestante: 5,
              periodo: 3,
              anoReferencia: 2024,
            ),
            isMembro: false,
            onSolicitar: (concessao, dataInicial, numeroDias) async {
              numeroDiasEnviado = numeroDias;
            },
          ),
        ),
      );

      await tester.tap(find.text('Marcar gozo'));
      await tester.pumpAndSettle();
      await _selecionarDataInicial(tester, sexta);
      await tester.enterText(find.byType(TextField), '2');
      await tester.pumpAndSettle();

      expect(find.textContaining('inclui sábado'), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Solicitar marcação'),
      );
      expect(button.onPressed, isNull);
      expect(numeroDiasEnviado, isNull);
    });

    testWidgets('erro da api ao marcar gozo aparece dentro do modal', (
      tester,
    ) async {
      final dataInicial = _proximaDataComDiaSemana(DateTime.tuesday);

      await tester.pumpWidget(
        _wrap(
          ConcessaoAfastamentoCard(
            concessao: const ConcessaoAfastamento(
              id: 10,
              tipo: TipoConcessao.licencaEleitoral,
              diasConcedidos: 5,
              saldoRestante: 5,
              periodo: 3,
              anoReferencia: 2024,
            ),
            isMembro: false,
            onSolicitar: (concessao, dataInicial, numeroDias) async {
              throw DioException(
                requestOptions: RequestOptions(path: '/solicitacoes'),
                response: Response(
                  requestOptions: RequestOptions(path: '/solicitacoes'),
                  statusCode: 422,
                  data:
                      'As datas de licença eleitoral não podem incluir fins de semana ou feriados',
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Marcar gozo'));
      await tester.pumpAndSettle();
      await _selecionarDataInicial(tester, dataInicial);
      await tester.enterText(find.byType(TextField), '1');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Solicitar marcação'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Não foi possível solicitar'), findsOneWidget);
      expect(find.textContaining('Afastamento eleitoral'), findsOneWidget);
    });

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
            isMembro: false,
            onBuscarOperacoes: (_) async => [
              OperacaoSolicitacaoConcessao.adiar,
              OperacaoSolicitacaoConcessao.antecipar,
            ],
            onExecutarOperacao:
                (
                  solicitacao,
                  operacao, {
                  DateTime? data,
                  DateTime? dataFim,
                }) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alterar data'), findsOneWidget);
      expect(find.text('Adiar'), findsNothing);
      expect(find.text('Antecipar'), findsNothing);
    });

    testWidgets('separa movimentacoes e mostra dias solicitados para retorno', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ConcessaoAfastamentoDetailsSheet(
            concessao: ConcessaoAfastamento(
              id: 468153,
              tipo: TipoConcessao.ferias,
              diasConcedidos: 30,
              saldoRestante: 0,
              periodo: 1,
              anoReferencia: 2025,
              solicitacoes: [
                SolicitacaoConcessao(
                  id: 506100,
                  tipo: TipoSolicitacaoConcessao.gozo,
                  inicio: DateTime(2026, 9, 5),
                  fim: DateTime(2026, 9, 16),
                  status: StatusSolicitacaoConcessao.deferido,
                ),
                SolicitacaoConcessao(
                  id: 506839,
                  tipo: TipoSolicitacaoConcessao.interrupcao,
                  fim: DateTime(2026, 9, 16),
                  status: StatusSolicitacaoConcessao.confirmado,
                  diasInformados: 12,
                ),
                const SolicitacaoConcessao(
                  id: 506840,
                  tipo: TipoSolicitacaoConcessao.suspensaoTotal,
                  status: StatusSolicitacaoConcessao.confirmado,
                  diasInformados: 20,
                ),
              ],
            ),
            isMembro: true,
          ),
        ),
      );

      expect(find.text('Gozos programados'), findsOneWidget);
      expect(find.text('Movimentações e pendências'), findsOneWidget);
      expect(find.text('05/09/2026 a 16/09/2026'), findsOneWidget);
      expect(find.text('Interrupção a partir de 16/09/2026'), findsOneWidget);
      expect(find.text('Suspensão integral do gozo'), findsOneWidget);
      expect(find.text('12 dia(s) solicitados para retorno'), findsOneWidget);
      expect(find.text('20 dia(s) solicitados para retorno'), findsOneWidget);
      expect(
        find.text('Aguardando análise do 2º Subprocurador-Geral'),
        findsNWidgets(2),
      );
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
            isMembro: false,
            onBuscarOperacoes: (_) async => [
              OperacaoSolicitacaoConcessao.adiar,
              OperacaoSolicitacaoConcessao.antecipar,
            ],
            onExecutarOperacao:
                (
                  solicitacao,
                  operacao, {
                  DateTime? data,
                  DateTime? dataFim,
                }) async {},
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
    isMembro: false,
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

DateTime _proximaDataComDiaSemana(int weekday) {
  var date = DateTime.now().add(const Duration(days: 1));
  while (date.weekday != weekday) {
    date = date.add(const Duration(days: 1));
  }
  return date;
}
