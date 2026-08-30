import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/concessao_folga_provider.dart';
import '../services/concessao_folga_service.dart';
import 'widgets/concessao_folga_calendar.dart';
import 'widgets/concessao_folga_theme.dart';
import 'widgets/concessoes_vigentes_list.dart';

class ConcessaoFolgaPage extends ConsumerWidget {
  const ConcessaoFolgaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(concessaoFolgaProvider);
    final notifier = ref.read(concessaoFolgaProvider.notifier);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFDED4C5),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(child: _Header(state: state)),
            const SliverPersistentHeader(
              pinned: true,
              delegate: _TabsHeaderDelegate(),
            ),
          ],
          body: TabBarView(
            children: [
              ConcessaoFolgaCalendar(
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
                onNavigateToMonth: (d) => notifier.selecionarMesAno(d.month, d.year),
              ),
              ConcessoesVigentesList(
                concessoes: state.concessoes.concessoes,
                isLoading: state.concessoes.isLoading,
                errorMessage: state.concessoes.errorMessage,
                onRetry: () => notifier.carregarConcessoes(forceRefresh: true),
                onRefresh: () =>
                    notifier.carregarConcessoes(forceRefresh: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selecionarMesAno(
    BuildContext context,
    ConcessaoFolgaNotifier notifier,
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
          color: const Color(0xFFF8F0E5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x33936F52)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33432B1D),
              blurRadius: 24,
              offset: Offset(0, 12),
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
                color: ConcessaoFolgaColors.ink,
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
                        color: ConcessaoFolgaColors.brand,
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
                            ? ConcessaoFolgaColors.brand
                            : const Color(0xFFEDE1D1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? const Color(0x668F2A1D)
                              : const Color(0x26936F52),
                        ),
                      ),
                      child: Text(
                        _months[index],
                        style: TextStyle(
                          color: selected
                              ? const Color(0xFFFFF8EA)
                              : ConcessaoFolgaColors.muted,
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
              color: const Color(0xFFEDE1D1),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0x26936F52)),
            ),
            child: Icon(icon, color: ConcessaoFolgaColors.brand, size: 24),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ConcessaoFolgaState state;

  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 44),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x3DD6A92F), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(255, 221, 132, 0.14),
            offset: Offset(0, -1),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF241D19), Color(0xFF3A241D), Color(0xFF8F2A1D)],
          stops: [0.0, 0.46, 1.0],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE5B84C), Color(0xFFA96A1D)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color.fromRGBO(255, 222, 142, 0.44),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(36, 18, 12, 0.30),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: const Icon(
              Icons.event_available,
              color: Color(0xFF211713),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MINISTÉRIO PÚBLICO DA PARAÍBA',
                  style: TextStyle(
                    color: Color(0xFFE3C474),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Concessão de Folga',
                  style: TextStyle(
                    color: Color(0xFFFFF8EA),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Color.fromRGBO(0, 0, 0, 0.22),
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ConcessaoFolgaService.nomeMesAno(state.mesSelecionado),
                  style: const TextStyle(
                    color: Color(0xFFD8C5AA),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _TabsHeaderDelegate();

  @override
  double get minExtent => 82;

  @override
  double get maxExtent => 82;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF4).withAlpha(242),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0x66FFFFFF), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x263A241D),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Color(0x99FFFFFF),
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFFFFF8EA),
              unselectedLabelColor: ConcessaoFolgaColors.muted,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              indicator: BoxDecoration(
                color: ConcessaoFolgaColors.brand,
                borderRadius: BorderRadius.circular(17),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2E8F2A1D),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              tabs: const [
                Tab(
                  height: 46,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_month, size: 18),
                        SizedBox(width: 8),
                        Text('Calendário'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  height: 46,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Concessões'),
                      ],
                    ),
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
