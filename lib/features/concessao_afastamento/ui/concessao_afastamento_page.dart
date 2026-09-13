import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/widgets/hero_header_publico.dart';
import '../../carteira/providers/carteira_provider.dart';

import '../providers/concessao_afastamento_provider.dart';
import 'widgets/concessao_afastamento_calendar.dart';
import 'widgets/concessao_afastamento_theme.dart';
import 'widgets/concessoes_vigentes_list.dart';

class ConcessaoAfastamentoPage extends ConsumerWidget {
  const ConcessaoAfastamentoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(concessaoAfastamentoProvider);
    final notifier = ref.read(concessaoAfastamentoProvider.notifier);
    final usuario = ref.watch(carteiraProvider).data;
    final tipoCargo = usuario?.tipoCargo?.trim().toUpperCase();
    final isMembro = tipoCargo == 'M' || tipoCargo == 'MEMBRO';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8F6),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            const SliverToBoxAdapter(child: _Header()),
            const SliverPersistentHeader(
              pinned: true,
              delegate: _TabsHeaderDelegate(),
            ),
          ],
          body: TabBarView(
            children: [
              ConcessaoAfastamentoCalendar(
                mes: state.mesSelecionado,
                ausencias: state.calendario.ausencias,
                isLoading: state.calendario.isLoading,
                errorMessage: state.calendario.errorMessage,
                onRetry: () => notifier.carregarAusencias(forceRefresh: true),
                onRefresh: () => notifier.carregarAusencias(forceRefresh: true),
                onPreviousMonth: () => notifier.mudarMes(-1),
                onNextMonth: () => notifier.mudarMes(1),
                onSelectMonth: () =>
                    _selecionarMesAno(context, notifier, state.mesSelecionado),
                onNavigateToMonth: (d) =>
                    notifier.selecionarMesAno(d.month, d.year),
              ),
              ConcessoesVigentesList(
                concessoes: state.concessoes.concessoes,
                isMembro: isMembro,
                isLoading: state.concessoes.isLoading,
                errorMessage: state.concessoes.errorMessage,
                onRetry: () => notifier.carregarConcessoes(forceRefresh: true),
                onRefresh: () =>
                    notifier.carregarConcessoes(forceRefresh: true),
                onSolicitar: (concessao, dataInicial, numeroDias) =>
                    notifier.solicitarGozo(
                      concessao: concessao,
                      dataInicial: dataInicial,
                      numeroDias: numeroDias,
                    ),
                onBuscarSugestoes: (concessao, dataInicial) =>
                    notifier.buscarSugestoesDatasFinais(
                      concessao: concessao,
                      dataInicial: dataInicial,
                    ),
                onBuscarOperacoes: (solicitacao) => notifier
                    .buscarOperacoesSolicitacao(solicitacao: solicitacao),
                onExecutarOperacao: (solicitacao, operacao, {data, dataFim}) =>
                    notifier.executarOperacaoSolicitacao(
                      solicitacao: solicitacao,
                      operacao: operacao,
                      data: data,
                      dataFim: dataFim,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selecionarMesAno(
    BuildContext context,
    ConcessaoAfastamentoNotifier notifier,
    DateTime selecionado,
  ) async {
    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) => _MonthYearPickerDialog(initialMonth: selecionado),
    );
    if (result != null) {
      await notifier.selecionarMesAno(result.month, result.year);
    }
  }
}

class _MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialMonth;

  const _MonthYearPickerDialog({required this.initialMonth});

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _selectedMonth;
  late int _selectedYear;

  static const _months = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth.month;
    _selectedYear = widget.initialMonth.year;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE9EDF0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14101828),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecionar mês',
              style: TextStyle(
                color: ConcessaoAfastamentoColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _YearButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => setState(() => _selectedYear--),
                  tooltip: 'Ano anterior',
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_selectedYear',
                      style: const TextStyle(
                        color: ConcessaoAfastamentoColors.brand,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                _YearButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => setState(() => _selectedYear++),
                  tooltip: 'Próximo ano',
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _months.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.4,
              ),
              itemBuilder: (context, index) {
                final month = index + 1;
                final selected = month == _selectedMonth;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(
                      context,
                    ).pop(DateTime(_selectedYear, month)),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF202322)
                            : const Color(0xFFF7F8F6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF202322)
                              : const Color(0xFFE9EDF0),
                        ),
                      ),
                      child: Text(
                        _months[index],
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : ConcessaoAfastamentoColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _YearButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _YearButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8F6),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFE9EDF0)),
            ),
            child: Icon(
              icon,
              color: ConcessaoAfastamentoColors.brand,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const HeroHeaderPublico(
      label: '',
      title: 'Concessão de Afastamento',
      subtitle: '',
      icon: Icons.event_available,
    );
  }
}

class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _TabsHeaderDelegate();

  @override
  double get minExtent => 58;

  @override
  double get maxExtent => 58;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF202322),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0x66FFFFFF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2A101828),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF202322),
              unselectedLabelColor: const Color(0xFFDDE4DF),
              labelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              tabs: const [
                Tab(
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, size: 17),
                      SizedBox(width: 5),
                      Flexible(child: Text('Calendário')),
                    ],
                  ),
                ),
                Tab(
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 17),
                      SizedBox(width: 5),
                      Flexible(child: Text('Concessões')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate oldDelegate) => false;
}
